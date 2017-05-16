#!/bin/bash

local_properties="/home/liang/daily-build-tools/local.properties"

homepanel_build_gradle="/home/liang/daily-build-tools/HomePanelBuildGradle/build.gradle"
homepanel_app_build_gradle="/home/liang/daily-build-tools/HomePanelAppBuildGradle/build.gradle"
homepanel_project_path="/home/liang/HomePanel/SourceCode/HomePanel"
homepanel_local_arm="$homepanel_project_path/app/src/main/obj/local"

sip_build_gradle="/home/liang/daily-build-tools/SipBuildGradle/build.gradle"
sip_app_build_gradle="/home/liang/daily-build-tools/SipAppBuildGradle/build.gradle"
sip_project_path="/home/liang/HomePanel/SourceCode/SipApp"
sip_local_arm="$sip_project_path/app/src/main/obj/local"

cp $local_properties $homepanel_project_path
cp $local_properties $sip_project_path

cp $homepanel_build_gradle $homepanel_project_path
cp $homepanel_app_build_gradle "$homepanel_project_path/app"

cp $sip_build_gradle $sip_project_path
cp $sip_app_build_gradle "$sip_project_path/app"

rm -rf $homepanel_local_arm
rm -rf $sip_local_arm
