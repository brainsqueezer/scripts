#!/usr/bin/python
# Little script to depack Matroska file, and repack them
# in a AVI + subtitle format.

# CodecID 'V_MS/VFW/FOURCC'  Container format: AVI (Microsoft
# CodecID 'A_VORBIS'  Container format: Ogg (Vorbis in Ogg
#-sws_flags  mmx mmx2 mmx2

#http://www.ibiblio.org/joey/videolinux/mp4-for-web-distribution-via-ffmpeg/
#   NTSC (4:3) size and framerate, deinterlaced
#   Video Codec: MPEG2 or MPEG4 (MPEG4 preferred)
#   Video Bitrate: at least 260Kbps (750kbps preferred)
#   Audio Codec: MP3 vbr
#   Audio Bitrate: at least 70Kbps (128 Kbps preferred) 

import sys
import os

def message(msg):
    print "=" * 78
    print "= %s" % msg
    print "=" * 78

def usage():
    print "Mastroka repacker script"
    print "  Usage: "+sys.wqargv[0]+ " filename"

if __name__ == "__main__":
   if len(sys.argv) < 2:
       usage()
   else:
       filename = sys.argv[1]
       basename = filename[:-4]

       message("Unpacking file: %s" % filename)
#       os.system("mkvextract tracks %s 1:temp_video.avi 2:temp_audio.ogg 3:%s.srt" % (filename,basename) )

       message("Repacking file: %s.avi" % basename)
       #same format
       #os.system("ffmpeg -i temp_audio.ogg  -i temp_video.avi  -vcodec copy  %s.avi" % (basename) )
       #google video
       #os.system("ffmpeg -i temp_audio.ogg  -i temp_video.avi -vcodec mpeg4 -r 29.97 -me full -re -b 2000 -acodec  copy -deinterlace  %s.avi" % (basename) )
       os.system("rm %s.avi"  % (basename) )
#os.system("ffmpeg -i temp_audio.ogg  -i temp_video.avi  -vcodec mpeg4  -vb 686k -ab 64k  -r 29.97  -re  -deinterlace  -me full  -acodec libmp3lame  %s.mpeg" % (basename) )

#the one
#os.system("ffmpeg -i temp_audio.ogg  -i temp_video.avi  -vcodec mpeg2  -vb 600k  -ab 64k  -r 29.97  -deinterlace  -acodec libmp3lame  %s.mpeg" % (basename) )
       os.system("ffmpeg -i temp_audio.ogg  -i temp_video.avi  -r 12 -vb 400k  -deinterlace  %s.mp4" % (basename) )

       message("Cleaning files")
       #  os.system("rm temp_video.avi temp_audio.ogg")
