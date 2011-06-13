#!/bin/bash
#2008 Ramon Antonio Parada <rap@ramonantonio.net> 

proceso="plasma" #Proceso a monitorizar
intervalo=1 #Intervalo en segundos
#Puedes ver todas las opciones disponibles con 'ps L'
params="comm=Command,%cpu=%CPU,%mem=%Mem,stat=State,thcount=Threads"


timestamp=`date +"%Y-%m-%d_%H:%M:%S"`
#psinfo=`ps -C 0 -o $params|tail -n 1`
topinfo=`top -n 1 -b | grep PID`
echo $timestamp $topinfo

while true; do 
   timestamp=`date +"%Y-%m-%d_%H:%M:%S"`
   #psinfo=`ps -C $proceso -o $params|tail -n 1`
   topinfo=`top -n 1 -b | grep $proceso`
   echo $timestamp $topinfo
   sleep $intervalo; 
done;

