# rpi-raspbian-opencv - Docker image of OpenCV for Raspberry Pi. #
This is a docker image of OpenCV compiled for the Raspberry Pi.  It includes python bindings for both Python2 and Python3.  
This uses balena.io Raspberry Pi base images and compiles OpenCV 3.3.1+ for python2 and python3.  
Installation is based upon instructions at http://www.pyimagesearch.com.

[![Docker Stars](https://img.shields.io/docker/stars/sgtwilko/rpi-raspbian-opencv.svg)]() [![Docker Stars](https://img.shields.io/docker/pulls/sgtwilko/rpi-raspbian-opencv.svg)]()

## How to Install / Use ##
Please see my [docker hub repo](https://hub.docker.com/r/sgtwilko/rpi-raspbian-opencv/) for instructions on installing and using this image.  
Most recent build is [![](https://images.microbadger.com/badges/version/sgtwilko/rpi-raspbian-opencv.svg)](https://microbadger.com/images/sgtwilko/rpi-raspbian-opencv "Get your own version badge on microbadger.com") which is [![](https://images.microbadger.com/badges/image/sgtwilko/rpi-raspbian-opencv.svg)](https://microbadger.com/images/sgtwilko/rpi-raspbian-opencv "Get your own image badge on microbadger.com").


## Building ##
You probably don't want to do this.  It's a right pain in the arse.

You will need a minimum of a 16GB SDCard, 32GB recommended and more than 7GB of free space.

Assuming you already have docker working on your system you will then need to increase the swap size on the RPi.  
To do this you will need to edit `/etc/dphys-swapfile`.

Comment out the line:
`#CONF_SWAPSIZE=100`
and uncomment and edit the remaining lines as follows:

	# set size to computed value, this times RAM size, dynamically adapts,
	#   guarantees that there is enough swap without wasting disk space on excess
	CONF_SWAPFACTOR=1
	
	# restrict size (computed and absolute!) to maximally this limit
	#   can be set to empty for no limit, but beware of filled partitions!
	#   this is/was a (outdated?) 32bit kernel limit (in MBytes), do not overrun it
	#   but is also sensible on 64bit to prevent filling /var or even / partition
	CONF_MAXSWAP=2048

Without this, the RPi will run out of RAM and will crash at around 86% during the build.

During building your RPi will run at 100% CPU for an extended amount of time.  It will run hot, I've seen mine hit 85°C.

I wouldn't recommend trying to build without a Heatsink, a fan is not necessary, but will speed up the process as the CPU will slow down as it reaches/exceeds 80°C.

A basic build will take between 2 and 4 hours on a RPi 3B, and can be kicked off by going into the rpi-raspbian-opencv folder and then running:

	docker build -t rpi-raspbian-opencv ./jessie

If you want to build for Raspbian Stretch you can do so by changing `./jessie` to `./stretch`  
The `-t` parameter is providing the tag you'll use to identify this image.

There are a couple of bash scripts that will build images located in the rpi-raspbian-opencv folder, but I wouldn't recommend using these as they are designed to rebuild all images, which will take multiple hours.
