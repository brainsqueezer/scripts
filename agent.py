#!/usr/bin/env python


#http://wiki.bluez.org/wiki/PasskeyAgent
#A simple passkey agent, invoke with arbitrary MAC/PIN pairs, i.e like 00:01:02:03:04:05/1234


import dbus
import dbus.glib
import dbus.service
import gobject
import sys

class PasskeyAgent(dbus.service.Object):
    def __init__(self, path, keystore):
        dbus.service.Object.__init__(self, dbus.SystemBus(), path)
        self.keystore = keystore

    @dbus.service.method(dbus_interface='org.bluez.PasskeyAgent',
                         in_signature='ssb', out_signature='s')
    def Request(self, path, address, numeric):
        try:
            pin = self.keystore[address]
            print "Request",path,address,numeric,"OK"
            return pin
        except:
            print "Request",path,address,numeric,"failed"
            return ""

if __name__ == "__main__":
    keystore = {}
    addr = "00:1A:45:94:44:F2"
    pin = "0000"
    keystore[addr] = pin
    print "Added ",addr," ",pin

    for arg in sys.argv:
        addr, pin = arg.split("/")
        keystore[addr] = pin
        print "Added ",addr," ",pin
    PATH = '/my/PasskeyAgent'
    bus = dbus.SystemBus();
    handler = PasskeyAgent(PATH, keystore)
    adapter = bus.get_object('org.bluez', '/org/bluez/hci0')
    sec = dbus.Interface(adapter, 'org.bluez.Security')
    ret = sec.RegisterDefaultPasskeyAgent(PATH)
    print "Return",ret
    main_loop = gobject.MainLoop()
    main_loop.run()
