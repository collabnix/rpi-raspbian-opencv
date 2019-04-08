#! /bin/bash

#Grab the ID of the latest image.
function fn_getID(){
	local tag=$1
	docker pull balena/rpi-raspbian:$tag
	fn_getID=$( docker images balena/rpi-raspbian:$tag --format "{{.ID}}" )
	#echo $fn_getID
}

#Add a tag to the new image, remove it from the old one first.
function fn_addTag(){
	echo "Tagging $myTag as sgtwilko/rpi-raspbian-opencv:$1"
	docker rmi sgtwilko/rpi-raspbian-opencv:$1
	docker tag $myTag sgtwilko/rpi-raspbian-opencv:$1
	docker push sgtwilko/rpi-raspbian-opencv:$1
}

pidfile=/var/run/lock/rpi-raspbian-opencv.pid

# exit if process is running
[ -f $pidfile ] && kill -0 `cat $pidfile` && exit
echo "$$" > $pidfile

echo 
echo 
echo --------- Starting ------------
echo 

#Get the ID of the balena/rpi-raspbain image tagged as latest.
fn_getID "latest"
latestID=$fn_getID

#If we need to force a full rebuild for some reason, even if the base images haven't changed.
rebuild=$1

opencv_versRaw=`./getOpenCVTags.sh`
#Array of supported OpenCV versions, latest version at the Start!
opencv_vers=($opencv_versRaw)

#Grab latest version (was the last in array (index -1), now the first, as the order changed.)
opencv_latest=${opencv_vers[0]}
#build date.
today=$(date -u +'%Y%m%d')
imageBuilt=0

for D in *; do
    if [ -d "${D}" ]; then
        echo "Checking ${D}..."
	echo ""
	fn_getID ${D}
	myID=$fn_getID
	lastID=$( cat ./${D}/rpi-raspbian.id )
	lastMaj=0
	if [[ ("$myID" != "$lastID") || ("$rebuild" == "1") ]]
	then
		for opencv_ver in "${opencv_vers[@]}"; do
			echo "Rebuilding for OpenCV $opencv_ver."
			myTag=sgtwilko/rpi-raspbian-opencv:${D}.$today-$opencv_ver
			majmin=$(echo "$opencv_ver" | awk -F. '{print $1"."$2}')
			major=$(echo "$opencv_ver" | awk -F. '{print $1}')
			#echo "$myTag"
			time docker build --build-arg OPENCV_VERSION=$opencv_ver --build-arg RASPBIAN_VERSION=${D} --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` --build-arg VCS_REF=`git rev-parse --short HEAD` -t $myTag ./${D}
			rc=$?; 
			date
			echo "done building for $opencv_ver."
			if [[ $rc != 0 ]]; 
			then 
				echo "Error building: $rc"
				exit $rc; 
			fi
			#Image built ok...
			((imageBuilt++))
			docker push $myTag
			fn_addTag ${D}-$opencv_ver
			fn_addTag ${D}-$majmin
			if [[ ("$major" != "$lastMaj") ]]
			then
				fn_addTag ${D}-$major
			fi
			if [[ ("$opencv_ver" == "$opencv_latest") ]]
			then
				fn_addTag ${D}-latest
				if [[ ("$myID" == "$latestID") ]]
				then
					fn_addTag latest-latest
					fn_addTag latest
				fi
			fi
			if [[ ("$myID" == "$latestID") ]]
			then
				fn_addTag latest-$majmin
				fn_addTag latest-$opencv_ver
				if [[ ("$major" != "$lastMaj") ]]
				then
					fn_addTag latest-$major
				fi
			fi
			lastMaj=$major
			#docker push
			echo "$myID" > ./${D}/rpi-raspbian.id
		done
	fi
    fi
done

echo 
echo ----------- All Done! -----------------
#if (( $imageBuilt > 0 ))
#then
#	docker push sgtwilko/rpi-raspbian-opencv
#fi
echo "$opencv_versRaw" > openCVVers.log
rm $pidfile
echo 
