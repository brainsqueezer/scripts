#!/usr/bin/env python
# -*- coding: iso-8859-15 -*- 
#
# Copyright 2007 by Philipp Kolmann (philipp@kolmann.at)
#
# Revision: $Id: action_handler.py 204 2009-08-25 13:55:07Z pkolmann $
# SVN URL:  $HeadURL: https://wspk.zid.tuwien.ac.at/svn/skype/trunk/action_handler.py/action_handler.py $
#
# This needs the Python DBus module.
#
# In Debian you can get it via: apt-get install python-dbus

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301,
# USA
#

import dbus
import sys
import re
import string

# Global Variables
DEBUG = 0

def call_skype(cmd):
	if DEBUG > 0: print cmd
	answer = skype.Invoke(cmd)
	if DEBUG > 0: print answer
	return answer

# Parse args
if len(sys.argv) != 2:
	print "Usage: "+sys.argv[0]+" SkypeCommand\n";
	sys.exit(-1)

user = ""
cmd  = ""
multiuser = 0

re1 = re.match('^(skype|callto|tel):\/?\/?([\+]?[\.\w-]+[;[\.\w-]+]?)\/?$', sys.argv[1]);
re2 = re.match('^(skype|callto|tel):\/?\/?([\+]?[\.\w-]+[;[\.\w-]+]?)\?(\w+)\/?$', sys.argv[1]);
re3 = re.match('^(skype):\/?\/?\?(chat)\&(blob)=([\.\w-]+)\/?$', sys.argv[1]);
if re1:
	user=re1.group(2)
	cmd ='call'

elif re2:
	user=re2.group(2)
	cmd =re2.group(3)
elif re3:
	cmd  = "chatblob"
	user = re3.group(4)
	print user
else:
	sys.exit("Invalid argument!\nLooking for skype:echo123?call")

if re.findall(';', user):
	print "multiuser!"
	multiuser = 1
	user = re.sub(';', ', ', user)

cmd = string.lower(cmd)

# Args parsed, connect to skype

remote_bus = dbus.SessionBus()
system_service_list = remote_bus.get_object('org.freedesktop.DBus',
	'/org/freedesktop/DBus').ListNames()

skype_api_found = 0
for service in system_service_list:
	if service=='com.Skype.API':
		skype_api_found = 1
		break

if not skype_api_found:
	sys.exit('No running API-capable Skype found')

skype = remote_bus.get_object('com.Skype.API', '/com/Skype')


answer = call_skype('NAME action_handler.py')
if answer != "OK":
	sys.exit('Error communicating with Skype!')

answer = call_skype('PROTOCOL 7')
if answer != "PROTOCOL 7":
	sys.exit('Skype client too old!')

# Connection work. Send Skype to command to work with it.

if cmd=='add':
	if multiuser:
		sys.exit('Command add takes only one user!')
	call_skype("OPEN ADDAFRIEND "+user)

elif cmd=='call':
	call_skype("CALL "+user)

elif cmd=='chat':
	answer = call_skype("CHAT CREATE "+user)
	chats=string.split(answer, ' ')
	call_skype("OPEN CHAT "+chats[1])

elif cmd=='chatblob':
	answer = call_skype("CHAT FINDUSINGBLOB "+user)
	chats=string.split(answer, ' ')
	if chats[0] == 'ERROR':
	    answer = call_skype("CHAT CREATEUSINGBLOB "+user)
	    chats=string.split(answer, ' ')
	answer = call_skype("ALTER CHAT "+chats[1]+" JOIN")
	answer = call_skype("OPEN CHAT "+chats[1])

elif cmd=='sendfile':
	call_skype("OPEN FILETRANSFER "+user)

elif cmd=='userinfo':
	if multiuser:
		sys.exit('Command userinfo takes only one user!\n')
	call_skype("OPEN USERINFO "+user)

else:
	sys.exit("Command "+cmd+" currently unhandled!")

