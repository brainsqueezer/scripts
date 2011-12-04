#!/bin/bash
#
# Author: Ramon Antonio Parada <ramon@bigpress.net>
#

function buscared() {
   local ifname=$1;
   local ssid=$2;
   SSID_AVAILABLE=$(/sbin/iwlist $ifname scan | grep "$ssid")
   if [ -n "$SSID_AVAILABLE" ]; then
      return 0
   fi
   return -1
    
 
}


#ssid[0]="valor_1"
#ssid[1]="valor_2"
#ssid[2]="valor_3"
#declare -p matriz
#for  e in ${matriz[*]}
#   do
#         echo $e
#            done

getifname() {
   ifname=`/sbin/iwconfig 2> /dev/null | grep IEEE`
   ifname=${ifname:0:4}
    eval "$1=ifname"
#http://www.mcwalter.org/technology/shell/functions.html
}



testbuscared() {
#averiguamos nombre de la interfaz
getifname $ifname
ssid="R-wlan2"

echo "Interfaz: $ifname"
echo "ssid: $ssid"


buscared $ifname $ssid
RESULTADO=$?
echo "Retorno: $RESULTADO"

if [ "$RESULTADO" -eq 0 ]; then
echo "biennn"
else
echo "maaaaaaal"
fi

}

testbuscared



