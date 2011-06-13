#!/usr/bin/python
# -*- coding: utf-8
#Version 0.2 by Alexandre González <alex _at_ rianxosencabos _dot_ com>
#All the bugs reserved ;)

#version 0.2: added a if to control the maximum of chars (140)

import urllib, urllib2, cookielib
import sys

if len(" ".join(sys.argv[1:])) > 140:
    print "Mensaxe demasiado larga, só se permiten 140 caracteres."
    quit()

if len(sys.argv) < 2:
    print "Necesito polo menos un argumento para postear como chío."
    quit()

#Global variables
@@NICKNAME = 'o_teu_nick'
@@PASSWORD = 'a_tua_pass'

#Make the cookie
cookie_h = urllib2.HTTPCookieProcessor()
opener = urllib2.build_opener( cookie_h )
urllib2.install_opener( opener )

#Login
params = urllib.urlencode( { "nickname" : NICKNAME, "password" : PASSWORD } )
req = urllib2.Request( "http://lareta.net/main/login", params )
response = urllib2.urlopen( req )

#Post the status message
params = urllib.urlencode( { 'status_textarea' : " ".join(sys.argv[1:]) } )
req = urllib2.Request( "http://lareta.net/notice/new", params )
response = urllib2.urlopen( req )

print "Chío publicado con éxito."