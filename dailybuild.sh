#!/bin/bash

FTP_SERVER_IMG="/Public/homepanel/dailybuild/img"
ANDROID_SRC="/home/liang/android6.01Src_20170602/android"
CURRENT_PATH="$( cd "$( dirname "$0" )" && pwd )"

function make_android()
{
if [ $1 -eq 0 ] || [ "$1" = "0" ]; then
    cp $HOME_PANEL_DEBUG_APK $ANDROID_SRC/packages/apps/HomePanel
    cp $SIP_DEBUG_APK $ANDROID_SRC/packages/apps/SipApp
    cp $FINAL_TEST_DEBUG_APK $ANDROID_SRC/packages/apps/FinalTest
    cd $ANDROID_SRC
    source build/envsetup.sh && lunch 24
    make -j8 > build_log 2>&1
    if [ $1 -eq 0 ]; then
        pack > pack_log 2>&1
        if [ $1 -eq 0 ]; then
            ftp_upload "/home/liang/android6.01Src_20170602/lichee/tools/pack/sun50iw1p1_android_p1_uart0.img" $FTP_SERVER_IMG
        else
            ftp_upload "/home/liang/android6.01Src_20170602/android/pack_log" $FTP_SERVER_IMG
        fi
    else
        ftp_upload "/home/liang/android6.01Src_20170602/android/build_log" $FTP_SERVER_IMG
    fi
else
    notify 1
    echo "retval is $1" >> "$TEMP_PATH/android_make_log"
    echo "apk failed to build some targets " >> "$TEMP_PATH/android_make_log"
fi
}

source $CURRENT_PATH/apk_dailybuild.sh
echo "ret: $ret" > "$TEMP_PATH/android_make_log"
make_android $ret