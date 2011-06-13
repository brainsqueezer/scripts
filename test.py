#!/usr/bin/python

import dbus
import sys
import os

#Types of NetworkManager devices
DEVICE_TYPE_UNKNOWN = 0
DEVICE_TYPE_802_3_ETHERNET = 1
DEVICE_TYPE_802_11_WIRELESS = 2

NM_DBUS_INTERFACE_DEVICES = "org.freedesktop.NetworkManager.Devices"
NM_DBUS_SERVICE = "org.freedesktop.NetworkManager"
NM_DBUS_INTERFACE = "org.freedesktop.NetworkManager"
NM_DBUS_PATH = "/org/freedesktop/NetworkManager"

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
			if dev.getType() == DEVICE_TYPE_802_11_WIRELESS:
				return dev
	GetWireless = staticmethod(GetWireless)

	def setActive(device, network):
		bus = dbus.SystemBus()
		nm = bus.get_object(NM_DBUS_SERVICE, NM_DBUS_PATH)
		nm.setActiveDevice(device, (bus.get_object(NM_DBUS_SERVICE, network)).getName())


class Network:
	def __init__(self, url):
		bus = dbus.SystemBus()
		nm = bus.get_object(NM_DBUS_SERVICE, NM_DBUS_PATH)
		net = bus.get_object(NM_DBUS_SERVICE, url)

		self.url = network
		self.name = net.getName()
		#activenetwork = dev.getActiveNetwork()
		self.encrypter = net.getEncrypted()
		self.strength = int (net.getStrength())

dev = Device.GetWireless()

networks = dev.getNetworks()
for network in networks:
	net = Network(network)
	print net.name + ' -> ' + str(net.strength)
	
	

