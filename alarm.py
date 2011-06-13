#!/usr/bin/env python
 
import time
import os
 
not_executed = 1
 
while(not_executed):
	time.sleep(0.5)
	dt = list(time.localtime())
	hour = dt[3]
	minute = dt[4]
	if hour == 7 and minute == 0:
		#si = file('/dev/null', 'r')
		#so = file('/dev/null', 'a+')
		os.popen2("mpg123 /home/rap/Music/aaaaa/Monchy\ \&\ Alexandra/Confesiones/02\ Dos\ Locos.mp3")
		#os.dup2(so.fileno(), o.fileno())
		#os.dup2(si.fileno(), i.fileno())
		not_executed = 0