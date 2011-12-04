#!/bin/bash
#
# Author: Ramon Antonio Parada <ramon@bigpress.net>
#

#for oldname in `ls -b -1F | grep \/$` ; do
#echo $oldname
#   newname=`echo $oldname | tr -cd "\\a-zA-Z0-9. "`
#   echo $newname
#   
#   if [ "$oldname" != "$newname" ] ; then
#	echo distintos
#	mv "$oldname" "$newname"
#    else
#	echo iguales
#    fi
    
    
#done
if  [ ${#1} -gt 0  ];
then
   dir=$1
else
   dir="."
fi

#find $dir -depth -exec rename -n 's/[^[:ascii:]]/_/g' {} \; | cat -v
find $dir -depth -exec rename 's/[^[:ascii:]]/_/g' {} \; | cat -v


#idea crear primero una funcion que actue como comando
# y luego pasarselo al find
