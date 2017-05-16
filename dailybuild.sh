#!/bin/bash
export PATH=$PATH:/home/liang/android-ndk-r13b

HOME_PATH="/home/liang"

HOMEPANEL_DIE="HomePanel/SourceCode/HomePanel"
SIP_DIE="HomePanel/SourceCode/SipApp"

GRADLE="$HOME_PATH/$HOMEPANEL_DIE/gradlew"

HOME_PANEL_PROJECT_PATH="$HOME_PATH/$HOMEPANEL_DIE"
HOME_PANEL_OUTPUT_PATH="$HOME_PANEL_PROJECT_PATH/app/build/outputs/apk"
HOME_PANEL_DEBUG_APK="$HOME_PANEL_OUTPUT_PATH/app-debug.apk"

SIP_PROJECT_PATH="$HOME_PATH/$SIP_DIE"
SIP_OUTPUT_PATH="$SIP_PROJECT_PATH/app/build/outputs/apk"
SIP_DEBUG_APK="$SIP_OUTPUT_PATH/app-debug.apk"

#CURRENT_PATH="$(cd `dirname $0`; pwd)"
CURRENT_PATH="$HOME_PATH/daily-build-tools"
FTP_SERVER="/Public/homepanel/dailybuild/app"

function make()
{
     source $CURRENT_PATH/svn_checkout_homepanel.sh
     chmod -R 777 $HOME_PANEL_PROJECT_PATH
     chmod -R 777 $SIP_PROJECT_PATH
     source $CURRENT_PATH/cp_build_gradle.sh

     $GRADLE -p $HOME_PANEL_PROJECT_PATH clean
     $GRADLE -p $SIP_PROJECT_PATH clean

     $GRADLE -p $HOME_PANEL_PROJECT_PATH build
     notify $?
     mv $HOME_PANEL_DEBUG_APK "$1/homepanel-debug-apk-`date +%Y%m%d%H%M`.apk"

     $GRADLE -p $SIP_PROJECT_PATH build
     notify $?
     mv $SIP_DEBUG_APK "$1/sip-debug-apk-`date +%Y%m%d%H%M`.apk"

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
         echo -n -e "${color_failed}#### make failed to build some targets "
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
