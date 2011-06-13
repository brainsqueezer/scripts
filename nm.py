#!/usr/bin/env python

import dbus


bus = dbus.SystemBus()

NetworkManager_obj = bus.get_object( 'org.freedesktop.NetworkManager', '/org/freedesktop/NetworkManager')
NetworkManager = dbus.Interface(NetworkManager_obj, 'org.freedesktop.NetworkManager')

Devices = []


for device_path in NetworkManager.getDevices():

	Devices.append( dbus.Interface( bus.get_object( 'org.freedesktop.NetworkManager', device_path), 'org.freedesktop.NetworkManager.Devices'))


Devices.reverse()

for device in Devices:
	print "\t getName() : " , device.getName()

# Console.WriteLine("NetworkState: " + etworkManager.state());

#props1 = dbus.Interface(eth0, 'org.freedesktop.DBus.Properties')
#devicetype = iface.get('org.freedesktop.NetworkManager.Device', 'DeviceType')

#print devicetype

#net0.Disconnprops1ect()
#nm.ActivateDevice(net0, 'org.freedesktop.NetworkManagerUserSettings', con1, con1)
