#!/bin/bash
root_build_gradle="/home/liang/daily-build-tools/HomePanelBuildGradle/build.gradle"
app_build_gradle="/home/liang/daily-build-tools/appBuildGradle/build.gradle"
local_properties="/home/liang/daily-build-tools/local.properties"
#local_arm="/home/liang/HomePanel/SourceCode/HomePanel/app/src/main/obj/local"
project_path="/home/liang/HomePanel/SourceCode/HomePanel"
local_arm="$project_path/app/src/main/obj/local"

cp $local_properties $project_path
cp $root_build_gradle $project_path
cp $app_build_gradle "$project_path/app"
rm -rf $local_arm

