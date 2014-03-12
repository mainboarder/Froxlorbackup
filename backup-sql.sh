#!/bin/bash
# 2014 by Mainboarder.de
#
# Keep this comment untouched and do not use this software for military purposes.
# you are allowed to use this just like you want on your own risk.
#
# contains lines from http://menzerath.eu/artikel/froxlor-alle-datenbanken-und-verzeichnisse-sichern/
#

temp="var/customers/temp-backup-path"
backuppath="/mnt/usb/backups"
encryption="/path/to/enc.key"
external="user@extern.server.de"
MYSQL_USER="root"
MYSQL_PASSWORD="root"

# Programm

# um <<tar - Entferne führende „/“ von Elementnamen>> zu vermeiden
cd /

#Datum erstellen
datum=$(date +"%d"."%m"."%y")

#Datenbanken finden
databases=`mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql)"`

#Datenbanken exportieren
for db in $databases; do
    mysqldump -u $MYSQL_USER -p$MYSQL_PASSWORD $db > "$temp/$db.sql"
done

# Alle SQL-Dumps in ein Archiv packen
tar cfvz $temp/../backup-sql-$datum.tar.gz $temp

#Verschlüsseln und gepackte Datei löschen
openssl aes-256-cbc -kfile $encryption -in $temp/../backup-sql-$datum.tar.gz -out $temp/backup-sql-$datum.enc.tar.gz

rm $temp/../backup-sql-$datum.tar.gz

#Kopieren und verschlüsselte Datei löschen
scp -i /etc/ssh/ssh_host_dsa_key $temp/backup-sql-$datum.enc.tar.gz $external:$backuppath

rm -r $temp
mkdir $temp
