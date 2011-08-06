#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# Copyright (C) 2006-2007, TUBITAK/UEKAE
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 2 of the License, or (at your
# option) any later version. Please read the COPYING file.
#

import os
import sys
import time
import dbus

I18N_NOOP = lambda x: x


CONNLIST, CONNINFO = range(1,3)


class Device:
	def __init__(self, devid, devname):
		self.mid = -1
		self.devid = devid
		self.devname = devname
		self.connections = {}
		self.menu_name = unicode(devname)
		if len(self.menu_name) > 25:
			self.menu_name = self.menu_name[:22] + "..."


class Connection:
	@staticmethod
	def hash(script, name):
		return unicode("%s %s" % (script, name))
	
	def __init__(self, script, data):
		self.mid = -1
		self.device = None
		self.script = script
		self.name = None
		self.devid = None
		self.devname = None
		self.remote = None
		self.apmac = None
		self.state = "unavailable"
		self.message = None
		self.net_mode = "auto"
		self.net_addr = None
		self.net_gateway = None
		self.parse(data)
		self.hash = self.hash(self.script, self.name)
		self.menu_name = unicode(self.name)
	
	def parse(self, data):
		for key, value in data.iteritems():
			if key == "name":
				self.name = value
			elif key == "device_id":
				self.devid = value
			elif key == "device_name":
				self.devname = value
			elif key == "remote":
				self.remote = value
			elif key == "apmac":
				self.apmac = value
			elif key == "net_mode":
				self.net_mode = value
			elif key == "net_address":
				self.net_addr = value
			elif key == "net_gateway":
				self.net_gate = value
			elif key == "state":
				if " " in value:
					self.state, self.message = value.split(" ", 1)
				else:
					self.state = value


class Link:
	def __init__(self, script, data):
		self.script = script
		self.remote_name = None
		for key, value in data.iteritems():
			if key == "type":
				self.type = value
			elif key == "name":
				self.name = value
			elif key == "modes":
				self.modes = value.split(",")
			elif key == "remote_name":
				self.remote_name = value



class DBusInterface:
	def __init__(self):
		self.state_hook = []
		self.ready_hook = []
		self.connections = {}
		self.devices = {}
		self.links = {}
		
		self.dia = None
		self.busSys = None
		self.busSes = None
		
		self.first_time = True
		self.nr_queried = 0
		self.nr_conns = 0
		self.nr_empty = 0
		self.winID = 0
		
		if self.openBus():
			self.setup()
	
	def openBus(self):
		try:
			self.busSys = dbus.SystemBus()
			self.busSes = dbus.SessionBus()
		except dbus.DBusException, exception:
			self.errorDBus(exception)
			return False
		return True
	
	def callHandler(self, script, model, method, action):
		ch = CallHandler(script, model, method, action, self.winID, self.busSys, self.busSes)
		ch.registerError(self.error)
		ch.registerDBusError(self.errorDBus)
		ch.registerAuthError(self.errorDBus)
		return ch
	
	def call(self, script, model, method, *args):
		try:
			obj = self.busSys.get_object("tr.org.pardus.comar", "/package/%s" % script)
			iface = dbus.Interface(obj, dbus_interface="tr.org.pardus.comar.%s" % model)
		except dbus.DBusException, exception:
			self.errorDBus(exception)
			return
		try:
			func = getattr(iface, method)
			return func(*args)
		except dbus.DBusException, exception:
			self.error(exception)
	
	def callSys(self, method, *args):
		try:
			obj = self.busSys.get_object("tr.org.pardus.comar", "/")
			iface = dbus.Interface(obj, dbus_interface="tr.org.pardus.comar")
		except dbus.DBusException, exception:
			self.errorDBus(exception)
		try:
			func = getattr(iface, method)
			return func(*args)
		except dbus.DBusException, exception:
			self.error(exception)
	
	def error(self, exception):
		print exception
	
	def errorDBus(self, exception):
		print exception
		sys.exit()
	
	def setup(self, first_time=True):
		if first_time:
			self.queryLinks()
	
	def handleSignals(self, *args, **kwargs):
		path = kwargs["path"]
		signal = kwargs["signal"]
		if not path.startswith("/package/"):
			return
		script = path[9:]

		if signal == "stateChanged":
			profile, state, msg = args
			conn = self.getConn(script, profile)
			if conn:
				conn.message = msg
				conn.state = state
				map(lambda x: x(), self.state_hook)
		elif signal == "connectionChanged":
			what, profile = args
			if what == "added" or what == "configured":
				ch = self.callHandler(script, "Net.Link", "connectionInfo", "tr.org.pardus.comar.net.link.get")
				ch.registerDone(self.handleConnectionInfo, script)
				ch.call(profile)
			elif what == "deleted":
				conn = self.getConn(script, profile)
				if conn:
					dev = self.devices.get(conn.devid, None)
					if dev:
						del dev.connections[conn.name]
						if len(dev.connections) == 0:
							del self.devices[dev.devid]
					map(lambda x: x(), self.state_hook)
	
	def listenSignals(self):
		self.busSys.add_signal_receiver(self.handleSignals, dbus_interface="tr.org.pardus.comar.Net.Link", member_keyword="signal", path_keyword="path")
	
	def queryLinks(self):
		scripts = self.callSys("listModelApplications", "Net.Link")
		if scripts:
			for script in scripts:
				info = self.call(script, "Net.Link", "linkInfo")
				self.links[script] = Link(script, info)
	
	def handleConnectionInfo(self, script, info):
		conn = Connection(script, info)
		old_conn = self.getConn(script, conn.name)
		if old_conn:
			if old_conn.devid != conn.devid:
				dev = self.devices.get(old_conn.devid, None)
				if dev:
					del dev.connections[old_conn.name]
					if len(dev.connections) == 0:
						del self.devices[dev.devid]
				dev = self.devices.get(conn.devid, None)
				if not dev:
					dev = Device(conn.devid, conn.devname)
					self.devices[conn.devid] = dev
				dev.connections[conn.name] = conn
			else:
				old_conn.parse(info)
			if self.first_time:
				map(lambda x: x(), self.state_hook)
			return
		dev = self.devices.get(conn.devid, None)
		if not dev:
			dev = Device(conn.devid, conn.devname)
			self.devices[conn.devid] = dev
		self.connections[conn.hash] = conn
		dev.connections[conn.name] = conn
		conn.device = dev
		if self.first_time:
			map(lambda x: x(), self.state_hook)
			# After all connections' information fetched...
			if self.nr_queried == len(self.links) and self.nr_conns == len(self.connections):
				self.first_time = False
				self.listenSignals()
				# Auto connect?
				map(lambda x: x(), self.ready_hook)
	
	def queryConnections(self, script):
		def handler(profiles):
			self.nr_queried += 1
			for profile in profiles:
				self.nr_conns += 1
				_ch = self.callHandler(script, "Net.Link", "connectionInfo", "tr.org.pardus.comar.net.link.get")
				_ch.registerDone(self.handleConnectionInfo, script)
				_ch.call(profile)
			if not len(profiles):
				self.nr_empty += 1
				# if no connections present, start listening for signals now
				if len(self.links) == self.nr_empty:
					if self.first_time:
						self.first_time = False
						# get signals
						self.listenSignals()
		ch = self.callHandler(script, "Net.Link", "connections", "tr.org.pardus.comar.net.link.get")
		ch.registerDone(handler)
		ch.call()
	
	def getConn(self, script, name):
		hash = Connection.hash(script, name)
		return self.connections.get(hash, None)
	
	def getConnById(self, mid):
		for dev in self.devices.values():
			for conn in dev.connections.values():
				if conn.mid == mid:
					return conn
		return None


comlink = DBusInterface()

