#!/bin/sh

# Disable wake-on-LAN because it draws power
ethtool -s eth0 wol d

# set moderately large PCI transfers by extending the PCI latency times
setpci -v -d *:* latency_timer=48 &> /dev/null


# lower the CPU voltage to save power (needs PHC patch)
[[ -f /sys/devices/system/cpu/cpu0/cpufreq/phc_vids ]] && echo 25 19 18 18 > /sys/devices/system/cpu/cpu0/cpufreq/phc_vids


# Never let output devices starve input devices, so start wide open on 
# input (memory, HD, network) and incrementally step down to output
# devices (sound, video)
setpci -v -s 00:00.0 latency_timer=ff # memory controller hub
setpci -v -s 00:1f.2 latency_timer=f0 # IDE controller
setpci -v -s 00:1d.7 latency_timer=e6 # USB2/ehci controller
setpci -v -s 02:00.0 latency_timer=e0 # Wired ethernet
setpci -v -s 0c:00.0 latency_timer=e0 # Wireless ethernet
setpci -v -s 00:02.0 latency_timer=d0 # Video controller
setpci -v -s 00:1b.0 latency_timer=c0 # Audio controller

# eliminate the ridiculously low memory allocation limits set by >2.6.16 kernels
# this specifically fixed growisofs memory allocation error in k3b
ulimit -l unlimited

# Add the 256MB video memory address range to the MTRR so xorg can make use of it
echo "base=0xc0000000 size=0x10000000 type=write-combining" >| /proc/mtrr

# enable process scheduling optimized for multicore processors
echo 1 > /sys/devices/system/cpu/sched_mc_power_savings

# Enable USB auto-suspend for all USB devices
for state in $(find /sys -name autosuspend -type f); do echo 1 > $state; done

# setup the ondemand frequency scaling and speed limits based on the power source
/etc/acpi/ac_adapter.sh

# enable sound card power savings
amixer set Line mute nocap
amixer set Mic mute nocap
echo Y > /sys/module/snd_ac97_codec/parameters/power_save

# Enable 1MB read ahead, write-caching, and disable 
# spindown and drive power management due to excessive
# head park/unpacking which kills laptop drives
hdparm -A1 -a1024 -W1 -B254 -S0 /dev/sda
for i in /sys/block/*/queue/read_ahead_kb; do echo 1024 > $i; done

# let the kernel recognize the custom buttons on the front of the laptop
setkeycodes e005 205 # reduce LCD brightness
setkeycodes e006 206 # increase LCD brightness
setkeycodes e007 207 # battery button
setkeycodes e008 208 # wireless toggle button
setkeycodes e009 209 # cdrom eject
setkeycodes e010 210 # hibernate
setkeycodes e011 211 # crt/lcd toggle
setkeycodes e012 212 # media direct
