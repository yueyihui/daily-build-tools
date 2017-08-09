#!/bin/bash

FTP_SERVER_IMG="/Public/homepanel/dailybuild/img"
ANDROID_SRC="/home/liang/android6.01Src_20170602/android"
CURRENT_PATH="$( cd "$( dirname "$0" )" && pwd )"

source $CURRENT_PATH/apk_dailybuild.sh

if [ $? -eq 0 ]; then
	cp $HOME_PANEL_DEBUG_APK $ANDROID_SRC/packages/apps/HomePanel
	cp $SIP_DEBUG_APK $ANDROID_SRC/packages/apps/SipApp
	cp $FINAL_TEST_DEBUG_APK $ANDROID_SRC/packages/apps/FinalTest
	cd $ANDROID_SRC
	source build/envsetup.sh && lunch 24
	make -j8 2>&1 | tee build_log
	if [ $? -eq 0 ]; then
		pack 2>&1 | tee pack_log
		if [ $? -eq 0 ]; then
			ftp_upload "/home/liang/android6.01Src_20170602/lichee/tools/pack/sun50iw1p1_android_p1_uart0.img" $FTP_SERVER_IMG
		else
			ftp_upload "/home/liang/android6.01Src_20170602/android/pack_log" $FTP_SERVER_IMG
		fi
	else
		ftp_upload "/home/liang/android6.01Src_20170602/android/build_log" $FTP_SERVER_IMG
	fi
else
	local log_file="log_`date +%Y%m%d`";
	echo "apk failed to build some targets " > "$CURRENT_PATH/log_file"
	echo "plase to view the log from ftp://159.99.249.113/Public/homepanel/dailybuild/app/`date +%Y%m%d`" >> "$CURRENT_PATH/log_file"
fi
