#!/bin/sh
#
# Author: Ramon Antonio Parada <ramon@bigpress.net>
#

git clone git://github.com/greghaynes/kdelicious.git
cd kdelicious/
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr
make
checkinstall -D make install

