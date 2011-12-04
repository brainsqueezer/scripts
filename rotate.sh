#!/bin/bash
#
# Author: Ramon Antonio Parada <ramon@bigpress.net>
#

#xrandr -o left
#xrandr -o right
#xrandr -o inverted
#xrandr -o normal

#xsetwacom set "TabletStylus" Rotate CW
#xsetwacom set "TabletStylus" Rotate HALF
#xsetwacom set "TabletStylus" Rotate CCW
#xsetwacom set "TabletStylus" Rotate NONE


#keycode 237 = XF86Launch0
#keycode 205 = XF86Launch1
#237 on DVD-näppäin ja 205 Quickplay.

#xmodmap ~/.Xmodmap



#Name                        Value
#run_command0_key      XF86Launch0
#run_command1_key      XF86Launch1

#Name                        Value
#command0       
#command1                    ~/rotation.sh



#Skripti toimii tällä versiossa 6.06 (Dapper Drake):
#rotation="$(xrandr -q | grep 'Current rotation' | cut -d' ' -f4)"

#Ja tällä versiossa 8.04 (Hardy Heron):

rotation="$(xrandr -q --verbose | sed -n '2 {p;q}' | cut -d' ' -f5)"

#xinput list con mode absolute

case "$rotation" in
    normal)
        xrandr -o right
        xsetwacom set "TabletStylus" Rotate CW
        xsetwacom set "TabletEraser" Rotate CW
        xsetwacom set "TabletTouch" Rotate CW
        ;;
    right)
        xrandr -o inverted
        xsetwacom set "TabletStylus" Rotate HALF
        xsetwacom set "TabletEraser" Rotate HALF
        xsetwacom set "TabletTouch" Rotate HALF
        ;;
    inverted)
        xrandr -o left
        xsetwacom set "TabletStylus" Rotate CCW
        xsetwacom set "TabletEraser" Rotate CCW
        xsetwacom set "TabletTouch" Rotate CCW
        ;;
    left)
        xrandr -o normal
        xsetwacom set "TabletStylus" Rotate NONE
        xsetwacom set "TabletEraser" Rotate NONE
        xsetwacom set "TabletTouch" Rotate NONE
        ;;
     default)
        xrandr -o right
        xsetwacom set "TabletStylus" Rotate CW
        xsetwacom set "TabletEraser" Rotate CW
        xsetwacom set "TabletTouch" Rotate CW
        ;;


 esac
