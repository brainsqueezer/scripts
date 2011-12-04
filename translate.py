#!/usr/bin/env python
#
# Author: Ramon Antonio Parada <ramon@bigpress.net>
#apt-get install libsox-fmt-all

#The following commands will look for 1.5 seconds worth of silence as a point to split.1
#Each progressive command line waits for x+1 periods of silence before begining copying the audio data.
#5% allows a threshold of some noise to still be considered complete silence. 

sox whole.wav song1.wav silence 0 1 00:00:01.5 5%
sox whole.wav song2.wav silence 1 00:00:01.5 5% 1 00:00:01.5 5%
sox whole wav song3.wav silence 2 00:00:01.5 5% 1 00:00:01.5 5%



#http://stackoverflow.com/questions/89228/how-to-call-external-command-in-python
from subprocess import call
import os

#partir o fichero en trozos



var = raw_input("Escuche el texto. Y escribalo a continuacion: ")
call(["play", "nobre de fichero"])
print "you entered ", var

var = raw_input("Introduzca la definicion: ")
os.path.exists('desktop\\somefile.txt')

start_path = r'/home/rap/Dropbox/test/'

def path_walk(the_path):
    cmd = 'ls ' + the_path 
    file_list = [item[:-1] for item in os.popen(cmd)]
    for the_file in file_list:
        if os.path.isdir(the_file):
            path_walk(os.path.join(the_path,the_file) )
        else:
            print the_file, 'is a file'
    return

path_walk(start_path)

#mp32wav
#mpg123 -s nombre_archivo.mp3 | sox -t raw -r 44100 -s -w -c 2 - nombre_archivo.wav


# wav2mp3 Para obtener un mp3 con un bitrate de 128:
#lame -h -m s -b 128 nombre_archivo.wav nombre_archivo-128.mp3



#ogg123 -d wav -f archivo.wav archivo.ogg
