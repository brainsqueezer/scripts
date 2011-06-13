#!/usr/bin/env python

"""CLI-based python interface to Network Manager.

Eric Wollesen <ericw at xmtp dot net>
"""

# NOTES:
#
# According to the README distributed with the Network Manager source
# package:
#     The nm-applet provides a DBUS service called NetworkManagerInfo,
#     which should provide to NetworkManager the Trusted and Preferred
#     Networks lists upon request.  It also should be able to display
#     a dialog to retrieve a WEP/WPA key or passphrase from the user
#     when NetworkManager requests it.  The GNOME version of
#     NetworkManagerInfo, for example, stores Trusted and Preferred
#     Networks in GConf and WEP/WPA keys in gnome-keyring, and proxies
#     that information to NetworkManager upon request.
#
# It seems that this then is our goal; to implement a matching
# NetworkManagerInfo service for dbus.

# RESOURCES:
# http://www.gnome.org/projects/NetworkManager/
# http://mail.gnome.org/archives/networkmanager-list/
# http://dbus.freedesktop.org/doc/dbus-tutorial.html#python-client

import csv
import getopt
import os
import signal
import sys
import time

import gobject 
import dbus
import dbus.service

if getattr(dbus, "version", (0,0,0)) >= (0,41,0):
    import dbus.glib

NM_PATH = "/org/freedesktop/NetworkManager"
NM_IFACE = "org.freedesktop.NetworkManager"
NMI_PATH = "/org/freedesktop/NetworkManagerInfo"
NMI_IFACE = "org.freedesktop.NetworkManagerInfo"


class Usage(Exception):

    def __init__(self, msg):
        self.msg = msg


class NetConfig(dict):
    """Parse and maintain networks specified in the config file.
    """

    def __init__(self):
        super(NetConfig, self).__init__()

    def add(self, essid, wep, *bssids):
        essid = unicode(essid)
        wep = unicode(wep)
        bssids = [unicode(bssid) for bssid in bssids]
        self[essid] = {"wep": wep, "bssids": bssids,}

    def GetNetworks(self):
        return self.keys()

    def GetNetworkProperties(self, essid):
        essid = unicode(essid)
        if essid in self.keys():
            return [dbus.String(essid), dbus.Int32(int(time.time())),
                    dbus.Boolean(True), self[essid]["bssids"], 16,
                    dbus.String(self[essid]["wep"]), 1]


class Config:
    """Read the config file.  

    Delegate queries about networks specified with the config file to the
    NetConfig class.
    """

    def __init__(self, filename):
        self._networks = NetConfig()
        self.reader = csv.reader(open(filename))
        for line in self.reader:
            if len(line) == 0 or line[0].strip().startswith("#"):
                continue
            #print >>sys.stderr, "line: '%s'" % line
            self._networks.add(*line)

    def GetNetworks(self):
        return self._networks.GetNetworks()

    def GetNetworkProperties(self, essid):
        return self._networks.GetNetworkProperties(essid)


class SignalHandler:

    def __init__(self):
        signal.signal(signal.SIGUSR1, self.ScanAndListAvailableNetworks)
        signal.signal(signal.SIGHUP, self.ReloadConfig)
        bus = dbus.SystemBus()
        nm_obj = bus.get_object(NM_IFACE, NM_PATH)
        nm = dbus.Interface(nm_obj, NM_IFACE)
        nm.connect_to_signal("WirelessNetworkAppeared", self.NetworkAppeared)

    def ScanAndListAvailableNetworks(self, signum, frame):
        pass

    def ReloadConfig(self, signum, frame):
        pass

    def NetworkAppeared(self, *args, **kwargs):
        print >>sys.stderr, "Network has appeared: %r %r" % (args, kwargs)

    def ScanAndListAvailableNetworks(self):
        pass




class PyNmObject(dbus.service.Object):
    """Provide a NetworkManagerInfo service.

    Allows NetworkManager to connect to user-specified wireless networks.
    """

    def __init__(self, configFilename="pynm.conf"):
        self._configFilename = configFilename
        self.ReloadConfig()
        busName = dbus.service.BusName(NMI_IFACE, bus=dbus.SystemBus())
        dbus.service.Object.__init__(self, busName, NMI_PATH)
        
    @dbus.service.method(NMI_IFACE)
    def getNetworks(self, *args, **kwargs):
        return self._config.GetNetworks()

    @dbus.service.method(NMI_IFACE, in_signature="si",
                         async_callbacks=("async_cb", "async_err_cb"))
    def getNetworkProperties(self, ssid, net_type, async_cb, async_err_cb):
        props = self._config.GetNetworkProperties(ssid)
        if props:
            # DBus workaround: the normal method return handler wraps the
            # returned arguments in a tuple and then converts that to a
            # struct, but NetworkManager expects a plain list of arguments.
            # It turns out that the async callback method return code
            # _doesn't_ wrap the returned arguments in a tuple, so as a
            # workaround use the async callback stuff here even though we're
            # not doing it asynchronously.
            #
            # http://dev.laptop.org/git.do?p=sugar;a=blob;h=f512a8b8d260a07a5029aff8cf2dadf05e383e53;hb=4384cc3f5bcf81a69bdc7c397973d231ca8b3c72;f=services/nm/nminfo.py
            return async_cb(*props)

    def ReloadConfig(self):
        self._config = Config(self._configFilename)



def main(argv=None):
    if argv is None:
        argv = sys.argv
    try:
        try:
            opts, args = getopt.getopt(argv[1:], "h", ["help"])
            for opt, val in opts:
                if opt in ("-h", "--help"):
                    raise Usage("No help written yet.")
        except getopt.error, msg:
            raise Usage(msg)
        
        obj = PyNmObject()
        sh = SignalHandler()
        mainloop = gobject.MainLoop()
        mainloop.run()

    except KeyboardInterrupt, err:
        return 0
    except Usage, err:
        print >>sys.stderr, err.msg
        print >>sys.stderr, "for help use --help"
        return 2


if __name__ == "__main__":
    sys.exit(main())
