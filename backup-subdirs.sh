#!/bin/bash
#
# Backup all directories within webroot
# use empty file ".DONT_BACKUP" to exclude any directory
#
#
#
# howto cron
# 15    0     *    *   *     $HOME/scripts/file_backup.sh > logfile.log
#
# TODO
# hacer ionice

 
# days to retain backup. Used by recycler script
DEFRETAIN=14
LOGFILE=/home/webb_e/site_backups/WebrootBackup.log
#
#
BU_FILE_COUNT=0
#
# and name of backup source subfolder under the users home
WEBDIR=/var/www/vhosts/
#
# and name of dest folder for tar files
DESDIR=~/site_backups
IONICE="ionice -c3"


#alright, thats it for config, the rest is script
#########################################

 
cd ${WEBDIR}
 
 
TODAY=`date`
BU_FILE_COUNT=0
suffix=$(date +%m-%d-%Y)
printf "\n\n********************************************\n\tSite Backup r Log for:\n\t" | tee -a $LOGFILE
echo $TODAY | tee -a $LOGFILE
printf "********************************************\n" $TODAY | tee -a $LOGFILE
echo "see ${LOGFILE} for details"
 
#for DIR in $(ls | grep ^[a-z.]*$) 
 
for DIR in $(ls | grep ^[a-z.]*$) 
do
	echo $DIR
	#tar the current directory
	if [ -f $DIR/.DONT_BACKUP ]
	then
 
		printf "\tSKIPPING $DIR as it contains ignore file\n" | tee -a $LOGFILE
 
	else
		cpath=${HOME}/${DESDIR}/${DIR}
		#
		#check if we need to make path
		#
		if [ -d $cpath ]
		then
			# direcotry exists, we're good to continue
			filler="umin"
		else
			echo Creating $cpath
			mkdir -p $cpath
			echo $DEF_RETAIN > $cpath/.RETAIN_RULE
		fi
		#
 
		${IONICE} tar -zcf ${HOME}/${DESDIR}/${DIR}/${DIR}_$suffix.tar.gz ./$DIR
		BU_FILE_COUNT=$(( $BU_FILE_COUNT + 1 ))
	fi
 
done
printf "\n\n********************************************\n" | tee -a $LOGFILE
echo $BU_FILE_COUNT sites were backed up
printf "********************************************\n" $TODAY | tee -a $LOGFILE

