#!/bin/bash


COUNTER=0
         while [  $COUNTER -lt 100 ]; do
sleep 60 
             let COUNTER=COUNTER+1 
             echo The counter is $COUNTER
         done


