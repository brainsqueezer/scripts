#!/bin/bash

###
##
# NAME			delcontain - delete files containing token
#
# SYNOPSYS		delcontain <sdir> <token>
#
# DESCRIPTION	Elimina todos los archivos dentro del directorio <sdir> que contienen <token> de forma recursiva
#
# AUTHOR Carolina F. Bravo <carolinafbravo@gmail.com>
# AUTHOR Ramon Antonio Parada <rap@ramonantonio.net>
##
###

if [ $# -lt 2 ]
then
	echo "ussage:: delcontain <sdir> <token>"
	exit -1
fi

DIR=$1
TOKEN=$2

if [ ! -d $DIR ]
then
	echo "$DIR is not a folder"
	exit -1
fi

echo "**scanning $DIR"

for line in `ls -1 $DIR`;
do
	ABS=$DIR/$line
	if [ -d $ABS ]
	then
#		echo "$ABS DIR"
		$0 $ABS $TOKEN
	elif [ -f $ABS ]
	then
#		echo "$ABS FILE"
		CONTAINS=`cat $ABS | grep $TOKEN`;

		if [[ ! $CONTAINS = "" ]]
		then
			echo "***deleting $ABS"
			rm $ABS
		fi
	fi
done

echo "**end-scanning $DIR"
