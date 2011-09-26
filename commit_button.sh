#!/bin/sh

var1=$(kdialog --title "Commit button" --inputbox "Texto del commit" "")
cd ~/Webs/diario
git commit -a -m "$var1"
git push; ./deploy.sh
cd ~/Webs/bp
git commit -a -m "$var1"
git push; ./deploy.sh


