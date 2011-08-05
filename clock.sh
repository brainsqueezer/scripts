#!/bin/bash
  while true 
  do 
    tput sc
    tput cup 0 60
    echo -en `date +"%H:%M:%S %F"`
    tput rc
    sleep 0.2
  done
