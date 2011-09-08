#!/bin/sh

cd ~/Webs/diario
var1=$(kdialog --title "Commit button" --inputbox "Texto del commit" "")
git add .
git commit -m "$var1"

