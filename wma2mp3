#!/bin/bash

###
##
# NAME			wma2mp3 - convert wma file to mp3
# 
# SYNOPSIS		wma2mp3 <srcdir> <destdir>
#
# DESCRIPTION	Convierte todos los ficheros .wma que contiene el directorio <srcdir> en mp3 
# 					y los almacena en el directorio <destdir>
##
###

if [ $# -lt 2 ]
then
	echo "ussage:: wma2mp3 <srcdir> <destdir>"
	exit -1;
fi

SRC_DIR=$1
DEST_DIR=$2

if [ ! -d $SRC_DIR ]
then
	echo "**$SRC_DIR is not a directory"
	exit -1;
fi

if [ ! -d $DEST_DIR ]
then
	echo "**creando $DEST_DIR"
	mkdir $DEST_DIR
fi

OLD_PWD=$PWD
cd $SRC_DIR
echo $SRC_DIR "**entrando en $SRC_DIR ----------"

tot=`ls -1 $PWD | grep wma | wc -l`
n=1

for line in `ls -1 $PWD`;
do
	ext=`echo $line | cut -f2 -d "."`
	if [[ $ext = "wma" ]]
	then
		name=`echo $line | cut -f1 -d "."`
		wmafile=$line
		wavfile=$name.wav
		mp3file=$DEST_DIR/$name.mp3

		echo "**($n de $tot) $name "
		n=$(( $n + 1 ));
		#echo "***WMA: $wmafile"	
		#echo "***WAV: $wavfile"
		#echo "***MP3: $mp3file"

		mplayer $wmafile -ao pcm:file=$wavfile > /dev/null 2> /dev/null
		lame $wavfile $mp3file > /dev/null 2> /dev/null
		rm $wavfile
	fi
done

cd $OLD_PWD
echo $SRC_DIR "**saliendo de $SRC_DIR ----------"
