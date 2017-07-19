#!/bin/bash
#
# Simple script for creating backups with Duplicity.
# Full backups are made on the 1st day of each month or with the 'full' option.
# Incremental backups are made on any other days.
#
# contains lines from http://menzerath.eu/artikel/froxlor-alle-datenbanken-und-verzeichnisse-sichern/
# and http://wiki.hetzner.de/index.php/Duplicity_Script
#
# USAGE: backup.sh [full]
#
# Keep this comment untouched and do not use this software for military purposes.
# you are allowed to use this just like you want on your own risk.
#

EMAIL="mail@example.com"

# get day of the month
DATE=`date +%d`

# Set protocol (use scp for sftp and ftp for FTP, see manpage for more)
BPROTO='ssh'

# set user and hostname of backup account
BUSER='user'
BHOST='host.example.com'

# Setting the password for the Backup account that the
# backup files will be transferred to.
# for sftp a public key can and should be used.
#BPASSWORD='yourpass'

# MySQL-root-access
mysql_backup=false
mysql_user="root"
mysql_password="P4aSsw04d"

# Backup iptables?
iptables=false

# Backup ip6tables?
ip6tables=false

# Temp Dir for SQL Backups (must exist)
temp="var/customers/temp_backup"

# directories to backup (but . for /)
BDIRS="etc var/customers"
ENDDIR="/media/hddmount/duplicity"
LOGDIR='/var/log/duplicity' # must exist

# Setting the pass phrase to encrypt the backup files. Will use symmetrical keys in this case.
# Set one Password per Backup
PASSPHRASE=$(/usr/bin/openssl rand -base64 21)
export PASSPHRASE

# encryption algorithm for gpg, disable for default (CAST5)
# see available ones via 'gpg --version'
ALGO=AES

##############################

IPTABLESEXEC=`which iptables-save`
IP6TABLESEXEC=`which ip6tables-save`

### MySQL Export
# Date create
datum=$(date +"%d"."%m"."%y")

cd /

# find all databases
if [ $mysql_backup = true ]; then
 databases=`mysql -u $mysql_user -p$mysql_password -e "SHOW DATABASES;" -Nsr | grep -Ev "(information_schema|performance_schema|mysql)"`

# export all databases
 for db in $databases; do
    mysqldump -u $mysql_user -p$mysql_password $db > "$temp/$db.sql"
 done
fi

# export iptables and ip6tables
if [ $iptables = true ]; then
 $IPTABLESEXEC > "$temp/iptables"
fi
if [ $ip6tables = true ]; then
 $IP6TABLESEXEC > "$temp/ip6tables"
fi

# save names of installed packages
dpkg --get-selections | awk '!/deinstall|purge|hold/ {print $1}' > "$temp/packages.list"

### Backup

if [ $ALGO ]; then
 GPGOPT="--gpg-options '--cipher-algo $ALGO'"
fi

if [ $BPASSWORD ]; then
 BAC="$BPROTO://$BUSER:$BPASSWORD@$BHOST/$ENDDIR"
else
 BAC="$BPROTO://$BUSER@$BHOST/$ENDDIR"
fi

# Check to see if we're at the first of the month.
# If we are on the 1st day of the month, then run
# a full backup. If not, then run an incremental
# backup.

if [ $DATE = 01 ] || [ "$1" = 'full' ]; then
 TYPE='full'
else
 TYPE='incremental'
fi

for DIR in $BDIRS
do
  if [ $DIR = '.' ]; then
    EXCLUDELIST='/usr/local/etc/duplicity-exclude.conf'
  else
    EXCLUDELIST="/usr/local/etc/duplicity-exclude-$DIR.conf"
  fi

  if [ -f $EXCLUDELIST ]; then
    EXCLUDE="--exclude-filelist $EXCLUDELIST"
  else
    EXCLUDE=''
  fi

  # first remove everything older than 1 month
  if [ $DIR = '.' ]; then
   CMD="duplicity remove-older-than 1M -v5 --force $BAC/system >> $LOGDIR/system.log"
  else
   CMD="duplicity remove-older-than 1M -v5 --force $BAC/$DIR >> $LOGDIR/$DIR.log"
  fi
  eval $CMD

  # do a backup
  if [ $DIR = '.' ]; then
    CMD="duplicity $TYPE -v5 $GPGOPT $EXCLUDE / $BAC/system >> $LOGDIR/system.log"
  else
    CMD="duplicity $TYPE -v5 $GPGOPT $EXCLUDE /$DIR $BAC/$DIR >> $LOGDIR/$DIR.log"
  fi
  eval  $CMD

done


# Delete SQL Exports
if [ $mysql_backup = true ]; then
 rm -r $temp
 mkdir $temp
fi

/usr/bin/mail -s "$(date) - $(hostname -f) - Backup complete!" $EMAIL <<< "Passphrase: ${PASSPHRASE}"

# Check the manpage for all available options for Duplicity.
# Unsetting the confidential variables
unset FTP_PASSWORD
unset PASSPHRASE

exit 0
