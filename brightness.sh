#!/bin/bash

CURRENT=$(grep "current:" /proc/acpi/video/UVGA/LCD/brightness |awk '{print $2}')


case "$CURRENT" in

100)
echo -n 100 > /proc/acpi/video/UVGA/LCD/brightness;
kdialog --passivepopup "Brightness already set to 100%" 3 &
;;
80)
echo -n 100 > /proc/acpi/video/UVGA/LCD/brightness;
kdialog --passivepopup "Brightness set to 100%" 3 &
;;
71)
echo -n 80 > /proc/acpi/video/UVGA/LCD/brightness;
kdialog --passivepopup "Brightness set to 90%" 3 &
;;
61)
echo -n 71 > /proc/acpi/video/UVGA/LCD/brightness;
kdialog --passivepopup "Brightness set to 80%" 3 &
;;
55)
echo -n 61 > /proc/acpi/video/UVGA/LCD/brightness;
kdialog --passivepopup "Brightness set to 70%" 3 &
;;
48)
echo -n 55 > /proc/acpi/video/UVGA/LCD/brightness;
kdialog --passivepopup "Brightness set to 60%" 3 &
;;
39)
echo -n 48 > /proc/acpi/video/UVGA/LCD/brightness;
kdialog --passivepopup "Brightness set to 50%" 3 &
;;
39)
echo -n 48 > /proc/acpi/video/UVGA/LCD/brightness;
kdialog --passivepopup "Brightness set to 40%" 3 &
;;
34)
echo -n 39 > /proc/acpi/video/UVGA/LCD/brightness;
kdialog --passivepopup "Brightness set to 30%" 3 &
;;
29)
echo -n 34 > /proc/acpi/video/UVGA/LCD/brightness;
kdialog --passivepopup "Brightness set to 20%" 3 &
;;
24)
echo -n 29 > /proc/acpi/video/UVGA/LCD/brightness;
kdialog --passivepopup "Brightness set to 15%" 3 &
;;
19)
echo -n 24 > /proc/acpi/video/UVGA/LCD/brightness;
kdialog --passivepopup "Brightness set to 10%" 3 &
;;
*)
echo -n 100 > /proc/acpi/video/UVGA/LCD/brightness ;
;;
esac 