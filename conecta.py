#!/usr/bin/python
import dbus
 
NM_DBUS_SERVICE = "org.freedesktop.NetworkManager"
NM_DBUS_INTERFACE = "org.freedesktop.NetworkManager"
NM_DBUS_OPATH = "/org/freedesktop/NetworkManager"

bus = dbus.SystemBus()
nm_obj = bus.get_object(NM_DBUS_SERVICE, NM_DBUS_OPATH)
nm = dbus.Interface(nm_obj, NM_DBUS_INTERFACE)

devices = nm.getDevices()

for op in devices:
    dev_obj = bus.get_object(NM_DBUS_SERVICE, op)
    dev = dbus.Interface(dev_obj, NM_DBUS_INTERFACE)
    props = dev.getProperties()
    print props
    
    if props[4] == True:
        nm.setActiveDevice(op)

