#!/bin/sh
#
# Author: Ramon Antonio Parada <ramon@bigpress.net>
# Convierte a formato compatible con YouTube
# Aun no funciona, Work in progress


ffmpeg \
-i test.mpg \ #input file
-y / # overides audio files
-f avi \ # format
-b 1150 \ # video bitrate in bits/s default 200kb/s
-s 320x240 \ # frame size
-r 29.97 \ # fps, frame rate Hz, defult 25 fps.
-g 12 \ # gop_size grup of pictures size
-qmin 3 \ # minimum video quantizer scale
-qmax 13 \ # maximum video quantizer scale
-ab 224 \ # audio bit rate
-ar 44100 \ # audio sampling frequency 
-ac 2 \ # audio channels
test.avi
