#!/bin/sh
kvm -m 320 -localtime  -hda /home/rap/Desktop/newhdd.img -cdrom /home/rap/Desktop/osxparcheado.iso -boot d
#./qemu -m 320 -localtime -user-net -hda /path/to/your/OSX/tiger-x86-flat.img -boot c
