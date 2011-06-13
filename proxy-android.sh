#!/bin/sh

CURDIR=`pwd`
cd /usr/local/share/android-sdk-linux_86/tools/ 
./adb forward tcp:8080 tcp:8080
cd $CURDIR


/home/rap/Dropbox/Scripts/kproxyswitch.sh 127.0.0.1:8080

