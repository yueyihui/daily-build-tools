#!/bin/bash
export PATH=$PATH:/home/liang/android-ndk-r13b

HOME_PATH="/home/liang"
HOMEPANEL_DIE="HomePanel/SourceCode/HomePanel"
GRADLE="$HOME_PATH/$HOMEPANEL_DIE/gradlew"
PROJECT_PATH="$HOME_PATH/$HOMEPANEL_DIE"
OUTPUT_PATH="$PROJECT_PATH/app/build/outputs/apk"
DEBUG_APK="$OUTPUT_PATH/app-debug.apk"
#CURRENT_PATH="$(cd `dirname $0`; pwd)"
CURRENT_PATH="$HOME_PATH/daily-build-tools"
FTP_SERVER="/Public/homepanel/dailybuild/app"

function make()
{
     source $CURRENT_PATH/svn_checkout_homepanel.sh
     chmod -R 777 $PROJECT_PATH
     source $CURRENT_PATH/cp_build_gradle.sh

     $GRADLE -p $PROJECT_PATH clean
     $GRADLE -p $PROJECT_PATH build
     notify $?
     mv $DEBUG_APK $1
     ftp_upload $1
}

function notify()
{
     color_failed="\e[0;31m"
     color_success="\e[0;32m"
     color_reset="\e[00m"
     if [ $1 -eq 0 ]; then
         echo -n -e "${color_success}#### make completed successfully "
     else
         echo -n "${color_failed}#### make failed to build some targets "
     fi
     echo -e " ####${color_reset}"
}

function ftp_upload()
{
     source $CURRENT_PATH/ftp_upload.sh $1 $FTP_SERVER
}

function svn_checkout_homepanel()
{
     source $CURRENT_PATH/svn_checkout_homepanel.sh
}

TEMP_PATH="$HOME_PATH/`date +%Y%m%d`"
if [ ! -d $TEMP_PATH ]; then
  mkdir $TEMP_PATH
fi
make $TEMP_PATH 2>&1 | tee "$TEMP_PATH/log"
