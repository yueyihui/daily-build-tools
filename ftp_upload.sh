#!/bin/bash
function upload_files() {
	#$1 is local path, split by / to get the remote path name that will mkdir
	OLD_IFS="$IFS"
	IFS="/"
	arr=($1)
	IFS="$OLD_IFS"

	#we got dir name
	local length=${#array_name[@]}
	local dir_name=${arr[length-1]}

	local HOST=159.99.249.113
	local USER=superhome
	local PASSWD=superhome

	#put files to server
ftp -n $HOST <<EOF
	user $USER $PASSWD
	binary
	hash
	cd $2
	mkdir $dir_name
	cd $dir_name
	lcd $1
	prompt
	mput *
	quit
EOF
}

function upload_file() {
	OLD_IFS="$IFS"
	IFS="/"
	arr=($1)
	IFS="$OLD_IFS"

	#we got dir name
	local length=${#array_name[@]}
	local file_name=${arr[length-1]}

	local dst_dir_name=`date +%Y%m%d`

	local HOST=159.99.249.113
	local USER=superhome
	local PASSWD=superhome

ftp -n $HOST <<EOF
	user $USER $PASSWD
	cd $2
	mkdir $dst_dir_name
	cd $dst_dir_name
	put $1 $file_name
	quit
EOF
}