#!/bin/bash
#
# Backup Script
#
# Original from http://www.cenolan.com/2008/05/simple-linux-to-amazon-s3-backup-script/
# Requires s3cmd
#
#=====================================================================
#=====================================================================
# Set the following variables to your system needs
#=====================================================================

# Directory to save daily tar.gz backup files to e.g /backups
BACKUPDIR="/backups"

# Directory to backup
BACKUPSRCDIR="/home"

# Maximum size of backup files in MB (larger files will be split into separate archives)
# Note: not implemented yet
MAXTARSIZE="1000"

# S3 Settings
# The name of the S3 bucket to upload to e.g. "my_s3_bucket"
S3BUCKET="my_s3_bucket"

# Mail setup
# What would you like to be mailed to you?
# - log   : send only log file
# - files : send log file and tar.gz files as attachments
# - stdout : will simply output the log to the screen if run manually.
# - quiet : Only send logs if an error occurs to the MAILADDR.
MAILCONTENT="log"

# Set the maximum allowed email size in k. (4000 = approx 5MB email [see docs])
MAXATTSIZE="4000"

# Email Address to send mail to? (user@domain.com)
MAILADDR="user@domain.com"

# Command to run before backups (uncomment to use)
#PREBACKUP="/etc/backup-pre"

# Command run after backups (uncomment to use)
#POSTBACKUP="/etc/backup-post"

#=====================================================================
#=====================================================================
#=====================================================================
#
# Should not need to be modified from here down!!
#
#=====================================================================
#=====================================================================
#=====================================================================
PATH=/usr/local/bin:/usr/bin:/bin:
DATE=`date +%Y-%m-%d_%Hh%Mm`                            # Datestamp e.g 2002-09-21
DOW=`date +%A`                                          # Day of the week e.g. Monday
DNOW=`date +%u`                                         # Day number of the week 1 to 7 where 1 represents Monday
DOM=`date +%d`                                          # Date of the Month e.g. 27
M=`date +%B`                                            # Month e.g January
W=`date +%V`                                            # Week Number e.g 37
VER=0.1                                                 # Version Number
HOST=`hostname`                                         # Hostname for LOG information
LOGFILE=$BACKUPDIR/$HOST-`date +%N`.log                 # Logfile Name
LOGERR=$BACKUPDIR/ERRORS_$HOST-`date +%N`.log           # Error log Name
BACKUPFILES=""

# Create required directories
if [ ! -e "$BACKUPDIR" ]                # Check Backup Directory exists.
then
mkdir -p "$BACKUPDIR"
fi

# IO redirection for logging.
touch $LOGFILE
exec 6>&1           # Link file descriptor #6 with stdout.
# Saves stdout.
exec > $LOGFILE     # stdout replaced with file $LOGFILE.
touch $LOGERR
exec 7>&2           # Link file descriptor #7 with stderr.
# Saves stderr.
exec 2> $LOGERR     # stderr replaced with file $LOGERR.

# Functions

# Backup function: removes last weeks archive from S3, creates new tar.gz and sends to S3
SUFFIX=""
dobackup () {
s3cmd ls s3://"$S3BUCKET" | grep s3 | sed "s/.*s3:\/\/$S3BUCKET\//s3:\/\/$S3BUCKET\//" | grep "$DOW" | xargs s3cmd del
tar cfz "$1" "$2"
echo
echo Backup Information for "$1"
gzip -l "$1"
echo
s3cmd put "$1" s3://"$S3BUCKET"
return 0
}

# Run command before we begin
if [ "$PREBACKUP" ]
then
echo ======================================================================
echo "Prebackup command output."
echo
eval $PREBACKUP
echo
echo ======================================================================
echo
fi

echo ======================================================================
echo BackupScript VER $VER
echo http://www.cenolan.com/
echo
echo Backup of Server - $HOST
echo ======================================================================

echo Backup Start Time: `date`
echo ======================================================================
# Daily Backup
echo Daily Backup of Directory \( $BACKUPSRCDIR \)
echo
echo Rotating last weeks Backup...
eval rm -fv "$BACKUPDIR/*.$DOW.tar.gz"
echo
dobackup "$BACKUPDIR/$DATE.$DOW.tar.gz" "$BACKUPSRCDIR"
BACKUPFILES="$BACKUPFILES $BACKUPDIR/$DATE.$DOW.tar.gz"
echo
echo ----------------------------------------------------------------------
echo Backup End Time: `date`
echo ======================================================================
echo Total disk space used for backup storage..
echo Size - Location
echo `du -hs "$BACKUPDIR"`
echo
echo ======================================================================
echo ======================================================================

# Run command when we're done
if [ "$POSTBACKUP" ]
then
echo ======================================================================
echo "Postbackup command output."
echo
eval $POSTBACKUP
echo
echo ======================================================================
fi

#Clean up IO redirection
exec 1>&6 6>&-      # Restore stdout and close file descriptor #6.
exec 1>&7 7>&-      # Restore stdout and close file descriptor #7.

if [ "$MAILCONTENT" = "files" ]
then
if [ -s "$LOGERR" ]
then
# Include error log if is larger than zero.
BACKUPFILES="$BACKUPFILES $LOGERR"
ERRORNOTE="WARNING: Error Reported - "
fi
#Get backup size
ATTSIZE=`du -c $BACKUPFILES | grep "[[:digit:][:space:]]total$" |sed s/\s*total//`
if [ $MAXATTSIZE -ge $ATTSIZE ]
then
BACKUPFILES=`echo "$BACKUPFILES" | sed -e "s# # -a #g"` #enable multiple attachments
mutt -s "$ERRORNOTE MySQL Backup Log and SQL Files for $HOST - $DATE" $BACKUPFILES $MAILADDR < $LOGFILE       #send via mutt
else
cat "$LOGFILE" | mail -s "WARNING! - Backup exceeds set maximum attachment size on $HOST - $DATE" $MAILADDR
fi
elif [ "$MAILCONTENT" = "log" ]
then
cat "$LOGFILE" | mail -s "Backup Log for $HOST - $DATE" $MAILADDR
if [ -s "$LOGERR" ]
then
cat "$LOGERR" | mail -s "ERRORS REPORTED: MySQL Backup error Log for $HOST - $DATE" $MAILADDR
fi
elif [ "$MAILCONTENT" = "quiet" ]
then
if [ -s "$LOGERR" ]
then
cat "$LOGERR" | mail -s "ERRORS REPORTED: Backup error Log for $HOST - $DATE" $MAILADDR
cat "$LOGFILE" | mail -s "Backup Log for $HOST - $DATE" $MAILADDR
fi
else
if [ -s "$LOGERR" ]
then
cat "$LOGFILE"
echo
echo "###### WARNING ######"
echo "Errors reported during Backup execution.. Backup failed"
echo "Error log below.."
cat "$LOGERR"
else
cat "$LOGFILE"
fi
fi

if [ -s "$LOGERR" ]
then
STATUS=1
else
STATUS=0
fi

# Clean up Logfile
eval rm -f "$LOGFILE"
eval rm -f "$LOGERR"

exit $STATUS