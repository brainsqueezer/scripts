#!/bin/sh
#
# Convierte los archivos MPC de un directorio al formato MP3
# uso: mpc2mp3

for f1 in *.mpc;
do
   f2=`echo $f1 | cut -d '.' -f 1`.mp3;
     mppdec-static "$f1" - | lame --r3mix - "$f2";
done
