#!/bin/sh

remote_dir="vacavella.dyndns.org:/home/rap/workspace/"
local_dir="/home/rap/workspace/"

project_dir="$2"
#rsync --partial -r -a -v -e "ssh"  /home/rap/tocopy/ 192.168.1.80:/home/rap/tocopy/
#rsync --partial --progress -r -a -v -e "ssh"  /home/rap/tocopy/ 192.168.2.10:/home/rap/tocopy/
#rsync --partial --progress --delete -u -n -r -a -v -e "ssh"  /home/rap/tocopy/ 192.168.1.80:/home/rap/tocopy/



#Early versions of SSH had the "-e none" option to disable encryption
#on the data channel.

#http://sial.org/howto/rsync/
#If speed is a concern, use a weaker encryption option to ssh.
# rsync -e 'ssh -ax -c blowfish' -avz example.org:/tmp .
#The -ax options to ssh disable Secure Shell (SSH) agent and X11 forwarding,
# which are not needed by rsync. Also consider setting -o ClearAllForwardings to ssh,
# to prevent possible automatic port forwards. For more information on options to OpenSSH,
# peruse ssh(1) and ssh_config(5).

case "$1" in
      up)
# rsync -n solo simulacion
echo "Up " $local_dir$project_dir
rsync --partial --progress --delete  -u -r -a -v -e 'ssh -ax -c blowfish'  $local_dir$project_dir $remote_dir
;;
      down)

echo "Down " $local_dir$project_dir
#tocopy
rsync --partial --progress --delete  -u -r -a -v -e 'ssh -ax -c blowfish'  $remote_dir$project_dir $local_dir
;;
      merge)

echo "Merge " $local_dir$project_dir
#tocopy
rsync --partial --progress -u -r -a -v -e 'ssh -ax -c blowfish'  $local_dir$project_dir $remote_dir$project_dir
rsync --partial --progress -u -r -a -v -e 'ssh -ax -c blowfish'  $remote_dir$project_dir $local_dir$project_dir
#-n solo prueba
#-u update skip if newer ion destination


        ;;
      serverlist)
	
	rsync -e 'ssh -ax -c blowfish'  $remote_dir

        ;;
      locallist)
	
	ls $local_dir
;;
      *)
      echo "Usage: $0 {serverlist|locallist|up|down|merge}"

   ;;
 esac

