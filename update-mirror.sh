#!/bin/sh  


echo "  Deleting Sources.gz and Packages.gz..."  
rm -f Sources.gz Packages.gz  
echo "  Scanning Sources (generating Sources.gz)..."  
dpkg-scansources . | gzip -9  > Sources.gz  
echo "  Scanning Packages (generating Packages.gz)..."  
apt-ftparchive packages . | gzip -9 >  Packages.gz  
echo "  Done!"  


#deb /home/ana/packages/ ./  
