#!/bin/sh
#http://ubuntuforums.org/archive/index.php/t-276885.html

#Muestra todas las escrituras en disco

echo 1 > /proc/sys/vm/block_dump


while true; do dmesg -c; sleep 1; done;


