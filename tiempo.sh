#!/bin/bash
#
# Author: Ramon Antonio Parada <ramon@bigpress.net>
#


cat tiempos.txt | while read line; do 
    echo $line
wget $line  -q -O - | grep "time]"

done
