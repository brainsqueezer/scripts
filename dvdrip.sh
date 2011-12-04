#!/bin/bash -x
#
# Author: Carolina F. Bravo <carolinafbravo@gmail.com
#
# Ripea un dvd y lo guarda como mkv

for EP in $(cat list.txt);

do

        # Umount existing image
        umount /media/cdrom0;

        # Mount image
        mount -t iso9660 -o loop /media/hda1/B5/$EP.iso /media/cdrom0;

        # Rip files
        nice -n20 mplayer -dvd-device /media/cdrom0 dvd://1 -v -dumpstream -dumpfile $EP.vob;
        nice -n20 mencoder -dvd-device /media/cdrom0 dvd://1 \
                -nosound -ovc frameno -o /dev/null -slang en -vobsubout $EP.en;
        nice -n20 mencoder -dvd-device /media/cdrom0 dvd://1 \
                -nosound -ovc frameno -o /dev/null -slang de -vobsubout $EP.de;

        echo "nice -n20 mplayer $EP.vob -ao pcm:file=$EP.wav -vc dummy -aid 128 -vo null";
        nice -n20 mplayer $EP.vob -ao pcm:fast:file=$EP.wav -vc dummy -aid 128 -vo null;

        nice -n20 normalize-audio $EP.wav;
        nice -n20 oggenc -q5 $EP.wav;


        # First pass
        nice -n20 \
                mencoder -v $EP.vob \
                -vf harddup \
                -ovc x264 \
                -x264encopts subq=4:bframes=3:b_pyramid:weight_b:turbo=1:pass=1:psnr:bitrate=1000 \
                -oac copy \
                -of rawvideo \
                -o $EP.264;

        # Second pass
        nice -n20 \
                mencoder -v $EP.vob \
                -vf harddup \
                -ovc x264 \
                -x264encopts subq=6:partitions=all:me=umh:frameref=5:bframes=3:b_pyramid:weight_b:pass=2:psnr:bitrate=1000 \
                -oac copy \
                -of rawvideo \
                -o $EP.264;

        nice -n20 MP4Box -add $EP.264 $EP.mp4;

        # Put it in matroska container
        nice -n20 \
                mkvmerge \
                -o $EP.mkv \
                -d 1 -A \
                -S $EP.mp4 \
                -a 0 -D -S $EP.ogg \
                --language 0:eng -s 0 -D -A $EP.en.idx \
                --language 0:ger -s 0 -D -A $EP.de.idx \
                --track-order 0:1,1:0,2:0,3:0;

        # Delete unused files
        rm $EP.vob;
        rm $EP.wav;
        rm $EP.264;
        rm $EP.en.idx;
        rm $EP.en.sub;
        rm $EP.de.idx;
        rm $EP.de.sub;
        rm $EP.mp4;
        rm $EP.ogg;
        rm divx2pass.log;

        chown hyper.hyper *;

        echo "$EP done";

done
