#!/bin/bash
# if nothing is passed to the script, show usage and exit
[[ -n "$1" ]] || { echo “Usage: findlarge [PATHNAME]“; exit 0 ; }
# simple using find, $1 is the first variable passed to the script
find $1 -type f -size +100000k -exec ls -lh {} \; | awk ‘{ print $9 “: ” $5 }’


#http://www.jarrodgoddard.com/linux-web-hosting/a-bash-script-to-find-large-files-on-a-linux-server
#repasar posibles fallos