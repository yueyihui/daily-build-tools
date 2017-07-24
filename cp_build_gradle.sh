#!/bin/bash

cp "$CURRENT_PATH/local.properties" $HOME_PANEL_PROJECT_PATH
cp "$CURRENT_PATH/local.properties" $SIP_PROJECT_PATH
cp "$CURRENT_PATH/local.properties" $FINAL_TEST_PROJECT_PATH

cp "$CURRENT_PATH/HomePanelBuildGradle/build.gradle" $HOME_PANEL_PROJECT_PATH
cp "$CURRENT_PATH/SipBuildGradle/build.gradle" $SIP_PROJECT_PATH
cp "$CURRENT_PATH/FinalTestBuildGradle/build.gradle" $FINAL_TEST_PROJECT_PATH

rm -rf "$HOME_PANEL_PROJECT_PATH/app/src/main/obj/local"
rm -rf "$SIP_PROJECT_PATH/app/src/main/obj/local"
rm -rf "$FINAL_TEST_PROJECT_PATH/app/src/main/obj/local"
