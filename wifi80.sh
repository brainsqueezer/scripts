#!/bin/sh
. /lib/lsb/init-functions

 YNAME="${0##*/}"
report() { echo "${MYNAME}: $*" ; }
report_err() { log_failure_msg "$*" ; }

ESSID="R-wlan2"
KEY="20080162000000000000000000"
INT="ath0"
modprobe ath5k


case "$1" in
      start)


	report "Setting up $INT..."
	modprobe ath5k
	/sbin/iwconfig $INT key $KEY essid $ESSID
	#/sbin/ifup $INT 
	ifconfig $INT 192.168.0.80 netmask 255.255.255.0 up
	route add default gw 192.168.0.2
cp /home/rap/Dropbox/misc/resolv.conf.bak /etc/resolv.conf   
   	;;

      manual)
	report "Setting up $INT manually..."
	ifconfig $INT 192.168.0.80 netmask 255.255.255.0 up
	route add default gw 192.168.0.2
	dhclient
   	;;

      restart | reload | force-reload)
        /etc/init.d/wifi stop
        /etc/init.d/wifi start
      ;;

      stop)
        /sbin/ifdown $INT 
	report "Setting down $INT..."
      ;;

      *)
    #  log_warning_msg "Usage: $0 {start|stop|restart|reload|force-reload}"
ping -c 1 www.google.com > /dev/null 2>&1

if [ $? -eq 0 ] ;
then
echo "ping succeeded"
else
echo "ping failed"
	report "Setting up $INT..."
	modprobe ath5k
	/sbin/iwconfig $INT key $KEY essid $ESSID
	#/sbin/ifup $INT 
	ifconfig $INT 192.168.0.80 netmask 255.255.255.0 up
	route add default gw 192.168.0.2
cp /home/rap/Dropbox/misc/resolv.conf.bak /etc/resolv.conf   
fi

    ;;
 esac

