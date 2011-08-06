#!/usr/bin/env python 

import urllib2
import csv
import dbus
import time
import signal
import gobject

#BUG1
#Traceback (most recent call last):
#  File "/home/rap/Scripts/ipoki.py", line 253, in <module>
#    s.daemon()
#  File "/home/rap/Scripts/ipoki.py", line 220, in daemon
#    self.update()
#  File "/home/rap/Scripts/ipoki.py", line 245, in update
#    self.positionx = self.positionx / self.strength
#ZeroDivisionError: integer division or modulo by zero

#BUG2
#Traceback (most recent call last):
#  File "/home/rap/Scripts/ipoki.py", line 260, in <module>
#    s.daemon()
#  File "/home/rap/Scripts/ipoki.py", line 227, in daemon
#    self.update()
#  File "/home/rap/Scripts/ipoki.py", line 239, in update
#    net.geo = GeoData(net.address)
#  File "/home/rap/Scripts/ipoki.py", line 100, in __init__
#    self.update(mac)
#  File "/home/rap/Scripts/ipoki.py", line 111, in update
#    for line in csv.reader(open(".ipoki").readlines()[1:]):
#IOError: [Errno 2] No such file or directory: '.ipoki'


#Types of NetworkManager devices
DEVICE_TYPE_UNKNOWN = 0
DEVICE_TYPE_802_3_ETHERNET = 1
DEVICE_TYPE_802_11_WIRELESS = 2

NM_DBUS_INTERFACE_DEVICES = "org.freedesktop.NetworkManager.Devices"
NM_DBUS_SERVICE = "org.freedesktop.NetworkManager"
NM_DBUS_INTERFACE = "org.freedesktop.NetworkManager"
NM_DBUS_PATH = "/org/freedesktop/NetworkManager"



class Ipoki:
	def __init__(self, user=None, pwd=None):
		self.user = user
		self.pwd =  pwd

#echo 'CODIGO$$$'.[session id].'$$$'.[server URL].'$$$'.[0=no update, 1=optional update, 2=must update].'$$$'
	def signin(self):
		url = 'http://www.ipoki.com/signin.php?user='+self.user+'&pass='+self.pwd
		try:
			usock = urllib2.urlopen(url)
			self.answer = usock.read()
			usock.close()
			data = self.answer.rsplit("$$$")
			self.sessionid = data[1]
			self.serverurl = data[2]
			self.update = data[3]
			return True
		except urllib2.URLError, (err):
			#print "URL error(%s)" % (err)
			return False
														
#Set the user's location.
	def ear(self, latitude='0', logintude='0', altitude='0', speed='0', to='', comment='', action='', statuschange=''):
		url = 'http://www.ipoki.com/ear.php?iduser='+self.sessionid+'&lat='+latitude+'&lon='+logintude+'&h='+altitude+'&speed='+speed+'&to='+to+'&comment='+comment+'&action='+action+'&change='+statuschange
		usock = urllib2.urlopen(url)
		self.answer = usock.read()
		usock.close()
		print 'ear -> '+self.answer

#if ($alert) {echo 'ALERT$$$' . [alert text] . '$$$' . [URL] . '$$$' . [latitud] . '$$$'
#   . [longitude] . '$$$' . [radio] . '$$$' . [username] .
#   '$$$'; } else if ($comment) {echo 'COMMENT$$$' . [user] . '$$$' . [comment] . '$$$' .
#   [action].'$$$';} else {echo 'OK'; }
#	 echo 'OK'; 
	def signout(self):
		url = 'http://www.ipoki.com/signout.php?iduser='+self.sessionid
		usock = urllib2.urlopen(url)
		self.answer = usock.read()
		usock.close()

# (-999.999999,-999.999999)
#
	def readposition(self):
		url = 'http://www.ipoki.com/readposition.php?iduser='+self.sessionid
		usock = urllib2.urlopen(url)
		self.answer = usock.read()
		usock.close()

		data = self.answer.rsplit(",")
		self.positionx = data[0]
		self.positiony = data[1]

#Get the status of a user.
#  echo '$$$'.[user status].'$$$'.{ON-OFF}.'$$$'
	def userstatus(self):
		url = 'http://www.ipoki.com/userstatus.php?iduser='+self.sessionid
		usock = urllib2.urlopen(url)
		self.answer = usock.read()
		usock.close()
		data = self.answer.rsplit("$$$")
		#print data
		self.status = data[2]

#email->nombre_red, mac, x, y, direccion
class GeoData:
	def __init__(self, mac):
		self.init = 1
		self.name = ''
		self.positionx = 0
		self.positiony = 0
		self.update(mac)
		#csv.register_dialect('unixpwd', delimiter=':', quoting=csv.QUOTE_NONE)

	def readall(self):
		l = []
		for line in csv.reader(open(".ipoki").readlines()[1:]):
			l.append(line)
		print l

# si falla return None
	def update(self, mac):
		for line in csv.reader(open(".ipoki").readlines()[1:]):
			#print line[0]+"/"+mac
			if line[0] == mac:
				#print line
				self.name = line[1]
				self.positionx = float(line[2])
				self.positiony = float(line[3])
				return True
		return False

	def write(self):
		writerow(row)


class Device:
	def GetDevices():
		bus = dbus.SystemBus()
		nm = bus.get_object(NM_DBUS_SERVICE, NM_DBUS_PATH)
		devices = nm.getDevices(dbus_interface=NM_DBUS_INTERFACE_DEVICES)
		return devices
	GetDevices = staticmethod(GetDevices)

	def GetWireless():
		bus = dbus.SystemBus()
		nm = bus.get_object(NM_DBUS_SERVICE, NM_DBUS_PATH)
		devices = Device.GetDevices()

		for device in devices:
			dev = bus.get_object(NM_DBUS_SERVICE, device)
		#activenetwork = dev.getActiveNetwork()
			if dev.getType() == DEVICE_TYPE_802_11_WIRELESS:
				return dev
	GetWireless = staticmethod(GetWireless)

	def setActive(device, network):
		bus = dbus.SystemBus()
		nm = bus.get_object(NM_DBUS_SERVICE, NM_DBUS_PATH)
		nm.setActiveDevice(device, (bus.get_object(NM_DBUS_SERVICE, network)).getName())


class Network:
	#message = dbus_message_new_signal (NMI_DBUS_PATH, NMI_DBUS_INTERFACE, "WirelessNetworkUpdate");
	#dbus_message_append_args (message, DBUS_TYPE_STRING, &network, DBUS_TYPE_INVALID);

	def __init__(self, url):
		bus = dbus.SystemBus()
		nm = bus.get_object(NM_DBUS_SERVICE, NM_DBUS_PATH)
		net = bus.get_object(NM_DBUS_SERVICE, url)

		self.url = url
		self.name = net.getName()
		#self.address = net.getAddress()
		self.encrypter = net.getEncrypted()
		self.strength = int(net.getStrength())
		self.getData()


	def getData(self):
		bus = dbus.SystemBus()
		networkdbus = bus.get_object('org.freedesktop.NetworkManager', self.url)
		networkprops = networkdbus.getProperties()
		#print 'networkprops -> '+str(networkprops)
		#networkprops -> (dbus.ObjectPath('/org/freedesktop/NetworkManager/Devices/wlan0/Networks/udcwifi_2d_wpa'), dbus.String(u'udcwifi-wpa'),2 dbus.String(u'00:0B:0E:1C:9E:46'), 3dbus.Int32(80), 4dbus.Double(2417000000.0), 5dbus.Int32(63872), 6dbus.Int32(2), 7dbus.Int32(16516), 8dbus.Boolean(True))
		#self.name = networkprops[1]
		self.address = networkprops[2]
		#self.strenght = str(networkprops[3])
		#self.frequency = str(networkprops[4])
		#self.rate = str(networkprops[5])
		#self.encrypted = str(networkprops[6])
		#self.p7 = str(networkprops[7])
		#self.encrypted = str(networkprops[8])

class SignalHandler:

	def __init__(self):
		signal.signal(signal.SIGUSR1, self.ScanAndListAvailableNetworks)
		signal.signal(signal.SIGHUP, self.ReloadConfig)
		bus = dbus.SystemBus()

		nm_obj = bus.get_object(NM_DBUS_INTERFACE, NM_DBUS_PATH)
		nm = dbus.Interface(nm_obj, NM_DBUS_INTERFACE)
		nm.connect_to_signal("WirelessNetworkAppeared", self.NetworkAppeared)

	def ScanAndListAvailableNetworks(self, signum, frame):
		print 'ScanAndListAvailableNetworks'
		pass

	def ReloadConfig(self, signum, frame):
		print 'ReloadConfig'
		pass

	def NetworkAppeared(self, *args, **kwargs):
		print "Network has appeared: %r %r" % (args, kwargs)

	def ScanAndListAvailableNetworks(self):
		print 'ScanAndListAvailableNetworks'
		pass

class Service:
	def __init__(self):
		 self.init()

	def init(self):
		self.ipoki = Ipoki("brainsqueezer", "4r5t6y7u")
		if self.ipoki.signin():
			self.ipoki.readposition()
			print "positionx: "+self.ipoki.positionx
			print "positiony: "+self.ipoki.positiony
			self.ipoki.userstatus()
			print "status: "+self.ipoki.status
			self.connected = True
		else:
			self.connected = False

	def daemon(self):
		while True:
			 self.update()
			 time.sleep(20)

	def update(self):
		if self.connected != True:
			 self.init()

		dev = Device.GetWireless()
		self.allnetworks = dev.getNetworks()
		self.geonetworks = []
		for neturl in self.allnetworks:
			 net = Network(neturl)
			 net.geo = GeoData(net.address)
			 if net.geo.positionx != 0:
				self.geonetworks.append(net)
			 print net.name +' mac -> '+net.address + ' -> ' + str(net.strength)+' ('+net.geo.name+' '+str(net.geo.positionx)+', '+str(net.geo.positiony)+')'

		self.positionx = 0
		self.positiony = 0
		self.strength = 0
		for net in self.geonetworks:
			self.positionx = self.positionx + net.geo.positionx*(net.strength^2)
			self.positiony = self.positiony + net.geo.positiony*(net.strength^2)
			self.strength = self.strength + (net.strength^2)

		self.positionx = self.positionx / self.strength
		self.positiony = self.positiony / self.strength
		print 'Triangulando... '+str(self.positionx)+','+str(self.positiony)
		#print 'Conectado a... '+geo.name+' ('+geo.positionx+', '+geo.positiony+')'
		self.ipoki.ear(str(self.positionx), str(self.positiony))


s = Service()
s.daemon()


#mainloop = gobject.MainLoop(set_as_default=True)
#mainloop.run()
#dbus.set_default_main_loop(mainloop)
#sh = SignalHandler()



#if __name__ == "__main__":
#	main()