#!/bin/bash
export PATH=$PATH:/opt/android-ndk

HOME_PATH="/home/liang"

HOMEPANEL_DIE="HomePanel/SourceCode/HomePanel"
SIP_DIE="HomePanel/SourceCode/SipApp"
FINAL_TEST_DIE="HomePanel/SourceCode/FinalTest"

GRADLE="$HOME_PATH/$HOMEPANEL_DIE/gradlew"

HOME_PANEL_PROJECT_PATH="$HOME_PATH/$HOMEPANEL_DIE"
HOME_PANEL_OUTPUT_PATH="$HOME_PANEL_PROJECT_PATH/app/build/outputs/apk"
HOME_PANEL_DEBUG_APK="$HOME_PANEL_OUTPUT_PATH/TunaDebug.apk"

SIP_PROJECT_PATH="$HOME_PATH/$SIP_DIE"
SIP_OUTPUT_PATH="$SIP_PROJECT_PATH/app/build/outputs/apk"
SIP_DEBUG_APK="$SIP_OUTPUT_PATH/SipDebug.apk"

FINAL_TEST_PROJECT_PATH="$HOME_PATH/$FINAL_TEST_DIE"
FINAL_TEST_OUTPUT_PATH="$FINAL_TEST_PROJECT_PATH/app/build/outputs/apk"
FINAL_TEST_DEBUG_APK="$FINAL_TEST_OUTPUT_PATH/FinalTestDebug.apk"

FTP_SERVER="/Public/homepanel/dailybuild/app"
CURRENT_PATH=${CURRENT_PATH-$( cd "$( dirname "$0"  )" && pwd )}

function tuna_build()
{
    source $CURRENT_PATH/svn_checkout_homepanel.sh
    chmod -R 777 $HOME_PANEL_PROJECT_PATH
    chmod -R 777 $SIP_PROJECT_PATH
    chmod -R 777 $FINAL_TEST_PROJECT_PATH
    source $CURRENT_PATH/cp_build_gradle.sh

    $GRADLE -p $HOME_PANEL_PROJECT_PATH clean
    $GRADLE -p $SIP_PROJECT_PATH clean
    $GRADLE -p $FINAL_TEST_PROJECT_PATH clean

    $GRADLE -p $HOME_PANEL_PROJECT_PATH assembleDebug
    if [ $? -eq 1 ]; then
        return 1
    else
        notify 0
        cp $HOME_PANEL_DEBUG_APK "$1/TunaDebug-`date +%Y%m%d%H%M`.apk"
    fi

    $GRADLE -p $SIP_PROJECT_PATH assembleDebug
    if [ $? -eq 1 ]; then
        return 1
    else
        notify 0
        cp $SIP_DEBUG_APK "$1/SipDebug-`date +%Y%m%d%H%M`.apk"
    fi

    $GRADLE -p $FINAL_TEST_PROJECT_PATH assembleDebug
    if [ $? -eq 1 ]; then
        return 1
    else
        notify 0
        cp $FINAL_TEST_DEBUG_APK "$1/FinalTestDebug-`date +%Y%m%d%H%M`.apk"
    fi

    ftp_upload $1 $FTP_SERVER
    return 0
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
    source $CURRENT_PATH/ftp_upload.sh
    if [ -d $1 ]; then
        upload_files $1 $2
    else
        upload_file $1 $2
    fi
}

function svn_checkout_homepanel()
{
    source $CURRENT_PATH/svn_checkout_homepanel.sh
}

TEMP_PATH="$HOME_PATH/`date +%Y%m%d`"
if [ ! -d $TEMP_PATH ]; then
    mkdir $TEMP_PATH
else
    rm -rf $TEMP_PATH
    mkdir $TEMP_PATH
fi
tuna_build $TEMP_PATH >"$TEMP_PATH/apk_build_log" 2>&1
ret=$?