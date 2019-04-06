#!/bin/bash


#git ls-remote --tags https://github.com/opencv/opencv | grep -v '{}\|-' | awk -F"/" '{print $3}' | sort -n -t. -k1,1 -k2,2 -k3,3 -k4,4 | awk -F"." '{if (($1>3) || ($1==3 && $2>3) || ($1==3 && $2==3 && $3>=1)) print $0;}'



#git ls-remote --tags https://github.com/opencv/opencv | grep -v '{}\|-' | awk -F"/" '{print $3}' | sort -n -t. -k1,1nr -k2,2nr -k3,3nr -k4,4nr | awk -F. '{if (!seen[$1$2]++ && mr<2) {print; mr++} } '

git ls-remote --tags https://github.com/opencv/opencv | grep -v '{}\|-' | awk -F"/" '{print $3}' | sort -n -t. -k1,1nr -k2,2nr -k3,3nr -k4,4nr | awk -F. '{if (!lr) {mr[$1]=2;mr[$1-1]=1;lr=$1} if (!seen[$1$2]++ && mr[$1]>0 && $1>2) {print; mr[$1]--} }'
