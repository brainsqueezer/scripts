#!/bin/sh
#
# Author: Ramon Antonio Parada <ramon@bigpress.net>
#


. /lib/lsb/init-functions

 YNAME="${0##*/}"
report() { echo "${MYNAME}: $*" ; }
report_err() { log_failure_msg "$*" ; }

case "$1" in
      start)

      echo "Extra performance: Message queues"
      echo 2048 > /proc/sys/kernel/msgmni
      echo 64000 > /proc/sys/kernel/msgmax


      echo "Extra performance: TCP"
      sysctl -w net.ipv4.tcp_keepalive_time=1800 &> /dev/null
      echo 30 > /proc/sys/net/ipv4/tcp_fin_timeout
echo "highspeed" > /proc/sys/net/ipv4/tcp_congestion_control
echo 1 > /proc/sys/net/ipv4/tcp_low_latency


      echo "Extra performance: Semaphores"
      echo 500 512000 64 2048 > /proc/sys/kernel/sem

echo "deadline io scheduler"
echo deadline > /sys/block/sda/queue/scheduler
      echo "Save Wireless"
#      iwconfig wlan0 power on
ifconfig wlan0 up

      echo "Save Bluetooth"
#      hciconfig hci0 down
 #     rmmod hci_usb

# enable process scheduling optimized for multicore processors
echo 1 > /sys/devices/system/cpu/sched_mc_power_savings

#ASPM PCI-Express power management
#http://blog.gwright.org.uk/articles/2008/12/30/x300-power-consumption-take-2
echo powersave > /sys/module/pcie_aspm/parameters/policy

# Disable wake-on-LAN because it draws power
ethtool -s eth0 wol d
#iwconfig wlan0 power 500m unicast
modprobe ieee80211_crypt_tkip
insmod /lib/modules/`uname -r`/misc/wl.ko


# set moderately large PCI transfers by extending the PCI latency times
#setpci -v -d *:* latency_timer=48 &> /dev/null

# enable sound card power savings
#amixer set Line mute nocap
#amixer set Mic mute nocap
#echo Y > /sys/module/snd_ac97_codec/parameters/power_save
#/sys/module/snd_hda_intel/parameters/power_save (default 300)


hdparm -B 192 /dev/sda
ifconfig eth0 down
      ;;
      restart | reload | force-reload)
        /etc/init.d/wifi stop
        /etc/init.d/wifi start
      ;;

      stop)
#	report down
      ;;

      *)
      log_warning_msg "Usage: $0 {start|stop|restart|reload|force-reload}"
    ;;
 esac

insmod /lib/modules/2.6.28/kernel/drivers/input/tablet/wacom.ko
