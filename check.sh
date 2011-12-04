#!/bin/sh
#
# Author: Ramon Antonio Parada <ramon@bigpress.net>
#

#export i=1171440236
#export j=1171440299
#
#b = (int)((L-S)*512/B)
# b = (314028801 - 67252224) * 512 / 4096
# b = 30847072

#b = File System block number
#B = File system block size in bytes
#L = LBA of bad sector
#S = Starting sector of partition as shown by fdisk -lu
#and (int) denotes the integer part.
root@neonlight:/home/rap/Dropbox/Scripts# debugfs
debugfs 1.41.9 (22-Aug-2009)
debugfs:  open /dev/sda2
debugfs:  testb 30847072
Block 30847072 marked in use
debugfs:  icheck 30847072
Block   Inode number
30847072        15417349
debugfs:  ncheck 15417349
Inode   Pathname
15417349        /home/rap/.kde/share/apps/ktorrent/log



(314028825 - 67252224) * 512 / 4096 =30847075
debugfs:  testb 30847075
Block 30847075 marked in use
debugfs:  icheck 30847075
Block   Inode number
30847075        15417349
debugfs:  ncheck 15417349
Inode   Pathname
15417349  



export j=314028801
export i=314028701

while [ $i != $j ]
do echo $i
dd if=/dev/sda of=/dev/null bs=512 count=1 skip=$i

let i+=1
done
