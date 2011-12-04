#!/bin/sh
# Author: Ramon Antonio Parada <ramon@bigpress.net>
# This script uses "dyndnsupdate" available at http://www.bebits.com/app/2927
# /etc/dhcp3/dhclient-exit-hooks.d/ddnsupdate



# HOSTNAME is your DynDNS hostname
HOSTNAME=brainsqueezer.dynalias.com
TTL=86400 # 24 hours
TTL=60 # 1 min
SETSERVER=members.dyndns.org
GETSERVER=checkip.dyndns.org
ZONE=dynalias.com
USER=brainsqueezer
PASS=123456789


# NSLOOKUP is the current DNS entry for your DynDNS hostname
NSLOOKUP=`/usr/bin/nslookup -sil $HOSTNAME | tail -2 | head -1 | cut -d" " -f2`

# CURRENT_IP is your router's current IP
CURRENT_IP=`/usr/bin/lynx -dump http://www.netins.net/dialup/tools/my_ip.shtml | grep -A2 "Your current IP Address is:" | tail -n1 | tr -d ' '`

echo "Server IP is $NSLOOKUP"
echo "Local IP is $CURRENT_IP"


# Is CURRENT_IP returning "unknown"?
if [ "$CURRENT_IP" = "unknown" ] ; then
   exit
fi


# Is our current IP in the DynDNS DNS records? If not, update them.
if [ "$NSLOOKUP" != "$CURRENT_IP" ] ; then
echo "Updating... "
/usr/bin/nsupdate -v << EOF
server $SERVER
update delete $HOSTNAME A
update add $HOSTNAME $TTL A $NSLOOKUP
send
EOF

# zone $ZONE
   # /sbin/dyndnsupdate -a $CURRENT_IP -h your_hostname.dyndns.org -m \
   # your_hostname's_mail_exchange.dyndns.org -s statdns \
   # -u dyndns.org_username:dyndns.org_password
   # Flush local DNS cache of $HOSTNAME
   /sbin/service named restart
else
 echo "Nothing to do"
fi



