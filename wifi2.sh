#!/bin/sh
. /lib/lsb/init-functions

 YNAME="${0##*/}"
report() { echo "${MYNAME}: $*" ; }
report_err() { log_failure_msg "$*" ; }

INT="wlan0"
#dhclient #para liberar
/etc/init.d/network-manager stop


case "$1" in
      start)
        ESSID="R-wlan2"
        KEY="20080162000000000000000000"
	report "Setting up $INT..."
	/sbin/iwconfig $INT key off 
	#/sbin/iwconfig $INT key $KEY essid $ESSID
	/sbin/iwconfig $INT essid $ESSID
	/sbin/iwconfig $INT key $KEY
	/sbin/ifconfig $INT up
	sleep 1
	dhclient $INT
   	;;
      udc)
        ESSID="udcportal"
	report "Setting up $INT..."
	/sbin/iwconfig $INT key off 
	/sbin/iwconfig $INT essid $ESSID
	/sbin/ifconfig $INT up
	sleep 1
	dhclient $INT
   	;;
      
      fnac)
        ESSID="fnac forum"
	report "Setting up $INT..."
	/sbin/iwconfig $INT key off 
	/sbin/iwconfig $INT essid "fnac forum" 
	/sbin/ifconfig $INT up
	sleep 1
	dhclient $INT
   	;;
      rosita)
        ESSID="villarosita"
	report "Setting up $INT..."
	/sbin/iwconfig $INT key off 
	/sbin/iwconfig $INT essid "villarosita" 
	/sbin/ifconfig $INT up
	sleep 1
	dhclient $INT
   	;;
      espacio)
	report "Setting up $INT..."
	/sbin/iwconfig $INT key off 
	/sbin/iwconfig $INT essid "ESPACIO CORU\xD1A" 
	/sbin/ifconfig $INT up
	sleep 1
	dhclient $INT
   	;;
      carlos)
        ESSID="VodafoneF5EF"
	report "Setting up $INT..."
	/sbin/iwconfig $INT key off 
	/sbin/iwconfig $INT essid "VodafoneF5EF" 
	/sbin/ifconfig $INT up
	sleep 1
	dhclient $INT
   	;;
      redondela)
	report "Setting up $INT..."
	/sbin/iwconfig $INT key off 
	/sbin/iwconfig $INT essid "CMG_RTC" 
	/sbin/ifconfig $INT up
	sleep 1
	dhclient $INT
   	;;
      
hollywood)
        ESSID="HOLLYWOOD"
        KEY="9998887776661"
	AP="00:50:7F:36:8B:2B"
	report "Setting up $INT..."
	#/sbin/iwconfig $INT essid $ESSID
	/sbin/iwconfig $INT ap $AP 
	/sbin/iwconfig $INT key $KEY 
	/sbin/ifconfig $INT up
	sleep 1
	dhclient $INT
   	;;
      
      
      forum)
	report "Setting up $INT..."
	ap1="00:01:F4:7C:F4:94"
	ap2="00:01:F4:7A:FB:E8"
	/sbin/iwconfig $INT key off 
#	/sbin/iwconfig $INT ap $ap1 essid "Wireless Municipal"
	/sbin/iwconfig $INT essid "Wireless Municipal"
#	/sbin/iwconfig $INT ap $ap2 
	/sbin/ifconfig $INT up
	dhclient $INT
   	;;

fon)
        /sbin/iwconfig $INT essid FON_AP
	/sbin/ifconfig $INT up
	dhclient $INT
   	;;
smc)
        /sbin/iwconfig $INT essid "SMC" 
	/sbin/ifconfig $INT up
	dhclient $INT
   	;;


      cabeiro)
        key="8650006806"
	essid="MyPlace"
	report "Setting up $INT..."
	/sbin/iwconfig $INT  essid "$essid"
	/sbin/ifconfig $INT up
	dhclient $INT
   	;;

      manual)
	report "Setting up $INT manually..."
	ifconfig $INT 192.168.0.1 netmask 255.255.255.0 up
	route add default gw 192.168.0.1
#	dhclient $INT
   	;;

      manual1)
	report "Setting up $INT manually..."
	ifconfig $INT 192.168.1.1 netmask 255.255.255.0 up
	route add default gw 192.168.1.1
#	dhclient $INT
   	;;

      adhoc)
	/sbin/iwconfig $INT key off 
#iwconfig wlan0 mode ad-hoc essid testb channel 1
iwconfig wlan0 mode ad-hoc
#iwconfig wlan0 essid uebksfyypreytpjoukdzbccptodvlwlg
iwconfig wlan0 essid test2 
iwconfig wlan0 channel 1
ifconfig wlan0 192.168.0.10 netmask 255.255.255.0 up
#dhclient wlan0
;;

      restart | reload | force-reload)
        /etc/init.d/wifi stop
        /etc/init.d/wifi start
      ;;

      stop)
        /sbin/ifdown $INT 
	report "Setting down $INT..."
      ;;
fic)

/etc/init.d/dhcdbd stop
/etc/init.d/dhcp3-server stop
/etc/init.d/wpa-ifupdown stop
killall wpa_supplicant


wpa_supplicant -iwlan0 -Dwext -c /home/rap/Dropbox/Scripts/wifi/wpasupplicant.conf
;;
      *)
      log_warning_msg "Usage: $0 {start|stop|restart|reload|force-reload}"
    ;;
 esac

