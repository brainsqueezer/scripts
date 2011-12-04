#!/bin/sh
#
# 
#
# ¿Qué usuario de Ubuntu no ha tenido a tenido alguna vez problemas las claves GPG
# de los repositorios?. Para solucionar esto está este script. Se ejecuta por
# consola especificando la version (karmic, jaunty, intrepid o hardy) y te busca
# las claves que te faltan. SOLO funciona con repositorios de Launchpad.

if [ "`whoami`" != "root" ];
then
echo "Please run with SUDO"
exit 1
fi
case "$1" in
hardy) RELEASE="hardy";;
intrepid) RELEASE="intrepid" ;;
jaunty) RELEASE="jaunty";;
karmic) RELEASR="karmic";;
*)
echo "Please select one of the following:"
echo "--"
echo "- karmic"
echo "- hardy"
echo "- intrepid"
echo "- jaunty"
echo "--"
echo "Example: sudo ./launchpad-update intrepid"
exit 1
;;
esac
echo Release: $RELEASE
echo Please Wait...
for q in `find /etc/apt/ -name *.list`; do
cat $q >> fullsourceslist
done
for i in `cat fullsourceslist | grep "deb http" | grep ppa.launchpad | grep $RELEASE | cut -d/ -f4`; do
	wget -q --no-check-certificate `wget -q --no-check-certificate https://launchpad.net/~$i/+archive -O- | grep "http://keyserver.ubuntu.com:11371/pks/" | cut -d'"' -f2 ` -O- | grep "pub  " | cut -d'"' -f2 >> keyss
done
for j in `cat keyss` ; do
	wget -q --no-check-certificate "http://keyserver.ubuntu.com:11371$j" -O- | grep -B 999999 END |grep -A 999999 BEGIN > keyss2
	sudo apt-key add keyss2
	rm keyss2
done
rm keyss
rm fullsourceslist

