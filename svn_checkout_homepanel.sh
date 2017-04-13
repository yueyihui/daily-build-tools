#!/bin/bash

LOCAL_DIR="/home/liang/HomePanel/"
REMOTE_DIR="https://acssvn.honeywell.com/HBT/Common/Home-Panel/branch/HomePanel/"

function checkout()
{
     svn checkout $REMOTE_DIR $LOCAL_DIR
}

function update()
{
  local local_version=`svn info $LOCAL_DIR | grep Revision|awk -F: '{ print $2}'`
  echo Local version is $local_version
  local remote_version=`svn info $REMOTE_DIR | grep Revision|awk -F: '{ print $2}'`
  echo Repo version is $remote_version
  if [ "$local_version" != "$remote_version" ]; then
     svn update $LOCAL_DIR
     if [ $? -ne 0 ];then
         echo "update local version:$local_version to remote version:$remote_version failure!!!"
     fi
  fi
}

if [ ! -d $LOCAL_DIR ]; then
     checkout
else
     update
fi
