#!/bin/bash
###
##
#
# NAME			delevil - delete evil files
#
# SYNOPSIS	 	delevil <efile> <spath>
#
# DESCRIPTION	borra todos los archivos maléficos de nombre <efile> recursivamenta a partir de la ruta <spath>
#
# NOTE			El path donde esta el script tiene que estar incluido en el PATH de bash
# 					PATH=$PATH:script_path; export PATH;
#
# AUTHOR Carolina F. Bravo <carolinafbravo@gmail.com>
# AUTHOR Ramon Antonio Parada <rap@ramonantonio.net>
##
###

#find . -name "Thumbs.db" -exec rm '{}' \;

if [ $# -lt 2 ]
then
	echo "ussage: delevil <efile> <spath>"
	exit -1;
fi

efile=$1
spath=$2
opath=$PWD

cd $spath
#echo "**scanning $PWD ----------"
ls -1 $PWD | while read line;
do
#	echo -n "[*]$line ";
	if [ -d $line ]
	then
#		echo "DIR"
#		echo "scanning $line"
		$0 $efile $line
	elif [ -f $line ]
	then
#		echo "FILE"
		if [[ $line = $efile ]]
		then
			echo "removing $PWD/$line"
			rm $line
		fi
#	else
#		echo "OTHER"
   fi
done

#echo "**end scanning $PWD ----------"
cd $opath
