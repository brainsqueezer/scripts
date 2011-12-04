#!/bin/bash
#
# author: Carolina F. Bravo <carolinafbravo@gmail.com>
#

if [ $# != 1 ]; then
	echo "usage: wifi-scan <interface>"
	exit
fi


IF="wlan0"
IF=$1
iwlist $IF scan | while read line; 
do 
	var=`echo $line | grep Address`
	if [ -n "$var" ]; then
		#ESSID:"WLAN_5A"
		printf "%15s" `echo -n "$line" | cut -f5 -d\ `
	fi

	var=`echo $line | grep ESSID`
	if [ -n "$var" ]; then
		#ESSID:"WLAN_5A"
		printf "%15s" `echo -n "$line" | cut -f2 -d\"`
	fi

	var=`echo $line | grep Quality`
	if [ -n "$var" ]; then
		#Quality=59/100  Signal level=-65 dBm
		echo -n " | `echo -n " $line" | cut -f2 -d= | cut -f1 -d/` %"
		echo  " | `echo -n " $line" | cut -f3 -d=`"
	fi

done
