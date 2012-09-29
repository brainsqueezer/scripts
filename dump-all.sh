#!/bin/bash
# Daniel Verner 
# CarrotPlant LLC
# 2011
# Backup each mysql databases into a different file, rather than one big file
# Optionally files can be gzipped (dbname.gz)
#
# Usage: dump_all_databases [ -u username -o output_dir -z ]
#		 
#	-u username to connect mysql server
#	-o [output_dir] optional the output directory where to put the files
#	-z gzip enabled
#
# Note: The script will prompt for a password, you cannot specify it as command line argument for security reasons
#
# based on the solution from: sonia 16-nov-05 (http://soniahamilton.wordpress.com/2005/11/16/backup-multiple-databases-into-separate-files/)
#
# TODO:
# http://serverfault.com/questions/94495/how-do-i-backup-a-mysql-database-but-at-low-priority

PROG_NAME=$(basename $0)
USER="root"
PASSWORD=""
OUTPUTDIR=~/db_backups
GZIP_ENABLED=1
GZIP=""

MYSQLDUMP="/usr/bin/mysqldump"
MYSQL="/usr/bin/mysql"

while getopts u:o:z OPTION
do
	case ${OPTION} in
		u) USER=${OPTARG};;
		o) OUTPUTDIR=${OPTARG};;
		z) GZIP_ENABLED=1;;
		?) echo "Usage: ${PROG_NAME} [ -u username -o output_dir -z ]"
		exit 2;;
	esac
done

if [ "$USER" != '' ]; then

	echo "Enter password for" $USER":"
	oldmodes=`stty -g`
	stty -echo
	read PASSWORD
	stty $oldmodes

fi


printf "\n\n********************************************\n\Database Backup r Log for:\n\t"
echo $TODAY 
printf "********************************************\n" $TODAY


if [ ! -d "$OUTPUTDIR" ]; then
	mkdir -p $OUTPUTDIR
fi

# get a list of databases
databases=`$MYSQL --user=$USER --password=$PASSWORD -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema)"`

# dump each database in turn
for db in $databases; do
	echo $db
	if [ $GZIP_ENABLED == 1 ]; then
		$MYSQLDUMP --force --opt --user=$USER --password=$PASSWORD --databases $db | gzip > "$OUTPUTDIR/$db.gz"
	else
		$MYSQLDUMP --force --opt --user=$USER --password=$PASSWORD --databases $db > "$OUTPUTDIR/$db.sql"
	fi
done


printf "\n\n********************************************\n" 
date
printf "\n\n********************************************\n" 
