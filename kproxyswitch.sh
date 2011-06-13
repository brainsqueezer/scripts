#!/bin/bash

### Proxy-Switcher for KDE
### Version 0.3 (2009-05-18)
### Patrick Nagel  (mail AT patrick - nagel DOT net)
### KDE4 port by Abhijit Bhopatkar  (bain AT devslashzero DOT com)

function print_help() {
	echo "Specify proxy as argument:"
	echo "$0 myproxy.example.com:3128"
	echo
	echo "or"
	echo
	echo "$0 off        switch off proxy usage"
	echo "$0 on         switch on proxy usage (sets last proxy again)"
	echo "$0 auto       switch on automatic proxy detection"
	exit 0
}

function error_cf_missing() {
	echo "The configuration file ${CF} does not exist,"
	echo "cannot continue."
	echo
	echo "Please change your proxy settings through KDE's dialogue once,"
	echo "which will cause the configuration file to be created."
	exit 1
}

function set_off() {
	sed -e "s/ProxyType=[0-9]/ProxyType=0/" -i ${CF}
	return
}

function set_on() {
	sed -e "s/ProxyType=[0-9]/ProxyType=1/" -i ${CF}
	return
}

function set_auto() {
	sed -e "s/ProxyType=[0-9]/ProxyType=3/" -i ${CF}
	return
}

function set_proxy() {
	sed -e "s/ProxyType=[0-9]/ProxyType=1/" \
	    -e "s/ftpProxy=.*/ftpProxy=http:\/\/${PROXY}/" \
	    -e "s/httpProxy=.*/httpProxy=http:\/\/${PROXY}/" \
	    -e "s/httpsProxy=.*/httpsProxy=http:\/\/${PROXY}/" -i ${CF}
	return
}

function tell_apps() {
	dbus-send --type=signal /KIO/Scheduler org.kde.KIO.Scheduler.reparseSlaveConfiguration string:""
}

# Main starts here

CF="${HOME}/.kde/share/config/kioslaverc"

echo "Proxy-Switcher for KDE"
echo

[ -f ${CF} ] || error_cf_missing

case "$1" in

        ("-h" | "--help" | "")
                print_help
        ;;

	("off")
		set_off && echo "Proxy usage switched off"
	;;

	("on")
		set_on && echo "Proxy usage switched on"
	;;

	("auto")
		set_auto && echo "Automatic proxy detection switched on"
	;;

        *)
		PROXY="$1"
                set_proxy && echo "Proxy set to $PROXY"
        ;;
esac

tell_apps
