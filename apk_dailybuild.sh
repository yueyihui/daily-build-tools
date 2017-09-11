#!/bin/bash
export PATH=$PATH:/opt/android-ndk

HOME_PATH="/home/liang"
PROJECT="/home/liang/HomePanel"
REMOTE_DIR="https://acssvn.honeywell.com/HBT/Common/Home-Panel/branch/HomePanel"

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
ftp -n $HOST <<FTP_SCRIPT
    user $USER $PASSWD
    binary
    cd $2
    mkdir $dir_name
    cd $dir_name
    lcd $1
    prompt
    mput *
    bye
    quit
FTP_SCRIPT
}

function upload_file() {
    OLD_IFS="$IFS"
    IFS="/"
    arr=($1)
    IFS="$OLD_IFS"

    #we got dir name
    local length=${#array_name[@]}
    local file_name=${arr[length-1]}

    local dist_dir="dailybuild-`date +%Y%m%d`"

    local HOST=159.99.249.113
    local USER=superhome
    local PASSWD=superhome

ftp -n $HOST <<FTP_SCRIPT
    user $USER $PASSWD
    binary
    cd $2
    mkdir $dist_dir
    cd $dist_dir
    put $1 $file_name
    bye
    quit
FTP_SCRIPT
}

function tuna_build()
{
    svn_go
    chmod -R 777 $HOME_PANEL_PROJECT_PATH
    chmod -R 777 $SIP_PROJECT_PATH
    chmod -R 777 $FINAL_TEST_PROJECT_PATH
    cp_build_gradle

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
    if [ -d $1 ]; then
        upload_files $1 $2
    else
        upload_file $1 $2
    fi
}

function checkout()
{
    svn checkout $REMOTE_DIR $PROJECT
}

function update()
{
  local local_version=`svn info $PROJECT | grep Revision|awk -F: '{ print $2}'`
  echo Local version is $local_version
  local remote_version=`svn info $REMOTE_DIR | grep Revision|awk -F: '{ print $2}'`
  echo Repo version is $remote_version
  if [ "$local_version" != "$remote_version" ]; then
     svn update $PROJECT
     if [ $? -ne 0 ];then
         echo "update local version:$local_version to remote version:$remote_version failure!!!"
     fi
  fi
}

function svn_go()
{
  if [ ! -d $PROJECT ]; then
      checkout
  else
      update
  fi
}

function cp_build_gradle()
{
#    cp "$CURRENT_PATH/local.properties" $HOME_PANEL_PROJECT_PATH
#    cp "$CURRENT_PATH/local.properties" $SIP_PROJECT_PATH
#    cp "$CURRENT_PATH/local.properties" $FINAL_TEST_PROJECT_PATH

#    cp "$CURRENT_PATH/HomePanelBuildGradle/build.gradle" $HOME_PANEL_PROJECT_PATH
#    cp "$CURRENT_PATH/SipBuildGradle/build.gradle" $SIP_PROJECT_PATH
#    cp "$CURRENT_PATH/FinalTestBuildGradle/build.gradle" $FINAL_TEST_PROJECT_PATH

    rm -rf "$HOME_PANEL_PROJECT_PATH/app/src/main/obj/local"
    rm -rf "$SIP_PROJECT_PATH/app/src/main/obj/local"
    rm -rf "$FINAL_TEST_PROJECT_PATH/app/src/main/obj/local"
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
echo "tuna_build return $ret" >> "$TEMP_PATH/apk_build_log"
if [ $ret -eq 0 ]; then
     ftp_upload $TEMP_PATH $FTP_SERVER
fi