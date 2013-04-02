#!/bin/bash
# 
# Original for 5.3 by Ruben Barkow (rubo77) http://www.entikey.z11.de/
# release 1 PHP5.4 to 5.3 by Emil Terziev ( foxy ) Bulgaria

# Originally Posted by Bachstelze http://ubuntuforums.org/showthread.php?p=9080474#post9080474
# OK, here's how to do the Apt magic to get PHP packages from the precise repositories:

echo "Am I root?  "
if [ "$(whoami &2>/dev/null)" != "root" ] && [ "$(id -un &2>/dev/null)" != "root" ] ; then
  echo "  NO!

Error: You must be root to run this script.
Enter
sudo su
"
  exit 1
fi
echo "  OK";


#install aptitude before, if you don`t have it:
apt-get update
apt-get install aptitude
# or if you prefer apt-get use:
# alias aptitude='apt-get'

# finish all apt-problems:
aptitude update
aptitude -f install
#apt-get -f install


# remove all your existing PHP packages. You can list them with dpkg -l| grep php
PHPLIST=$(for i in $(dpkg -l | grep php|awk '{ print $2 }' ); do echo $i; done)
echo these pachets will be removed: $PHPLIST 
# you need not to purge, if you have upgraded from precise:
aptitude remove $PHPLIST
# on a fresh install, you need purge:
# aptitude remove --purge $PHPLIST


#Create a file each in /etc/apt/preferences.d like this (call it for example /etc/apt/preferences.d/php5_2);
#
#Package: php5
#Pin: release a=precise
#Pin-Priority: 991
#
#The big problem is that wildcards don't work, so you will need one such stanza for each PHP package you want to pull from precise:

echo ''>/etc/apt/preferences.d/php5_3
for i in $PHPLIST ; do echo "Package: $i
Pin: release a=precise
Pin-Priority: 991
">>/etc/apt/preferences.d/php5_3; done

echo "# needed sources vor php5.3:
deb http://bg.archive.ubuntu.com/ubuntu/ precise main restricted
deb-src http://bg.archive.ubuntu.com/ubuntu/ precise main restricted

deb http://bg.archive.ubuntu.com/ubuntu/ precise-updates main restricted
deb-src http://bg.archive.ubuntu.com/ubuntu/ precise-updates main restricted

deb http://bg.archive.ubuntu.com/ubuntu/ precise universe
deb-src http://bg.archive.ubuntu.com/ubuntu/ precise universe
deb http://bg.archive.ubuntu.com/ubuntu/ precise-updates universe
deb-src http://bg.archive.ubuntu.com/ubuntu/ precise-updates universe

deb http://bg.archive.ubuntu.com/ubuntu/ precise multiverse
deb-src http://bg.archive.ubuntu.com/ubuntu/ precise multiverse
deb http://bg.archive.ubuntu.com/ubuntu/ precise-updates multiverse
deb-src http://bg.archive.ubuntu.com/ubuntu/ precise-updates multiverse
deb-src http://bg.archive.ubuntu.com/ubuntu/ natty-backports main restricted universe multiverse

deb http://security.ubuntu.com/ubuntu precise-security main restricted
deb-src http://security.ubuntu.com/ubuntu precise-security main restricted
deb http://security.ubuntu.com/ubuntu precise-security universe
deb-src http://security.ubuntu.com/ubuntu precise-security universe
deb http://security.ubuntu.com/ubuntu precise-security multiverse
deb-src http://security.ubuntu.com/ubuntu precise-security multiverse

deb-src http://archive.canonical.com/ubuntu natty partner

deb http://extras.ubuntu.com/ubuntu precise main
deb-src http://extras.ubuntu.com/ubuntu precise main

deb http://bg.archive.ubuntu.com/ubuntu/ precise-backports main restricted universe multiverse
deb-src http://bg.archive.ubuntu.com/ubuntu/ precise-backports main restricted universe multiverse


deb http://archive.canonical.com/ubuntu precise partner
deb-src http://archive.canonical.com/ubuntu precise partner

" >> /etc/apt/sources.list.d/precise.list

aptitude update

apache2ctl restart

echo install new from precise:
aptitude -t precise install $PHPLIST

# at the end retry the modul libapache2-mod-php5 in case it didn't work the first time:
aptitude -t precise install libapache2-mod-php5

apache2ctl restart
