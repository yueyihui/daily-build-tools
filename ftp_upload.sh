#!/bin/bash

################################################
####					    ####
####  ./ftp_upload debug-apk_dir dest_dir   ####
####					    ####
################################################
dir_path="$1"

#split dir_path by /
OLD_IFS="$IFS"
IFS="/"
arr=($dir_path)
IFS="$OLD_IFS"

#we got dir name
length=${#array_name[@]}
dir_name=${arr[length-1]}

#this dir is our destination
dest_dir="$2"

ip=159.99.249.113
user=superhome
password=superhome

#put dir to server
ftp -n <<!
open $ip
user $user $password
binary
hash
cd $dest_dir
mkdir $dir_name
cd $dest_dir/$dir_name
lcd $dir_path
prompt
mput *
close
bye
!
