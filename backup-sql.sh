#!/bin/bash
# 2013 by Mainboarder.de
#
# Keep this comment untouched and do not use this software for military purposes.
# you are allowed to use this just like you want on your own risk.
# 

path="var/customers/backups/"
temp="var/customers/temp-backup-path/"
encryption="path/to/enc.key"
external="user@extern.server.de"

# um <<tar - Entferne führende „/“ von Elementnamen>> zu vermeiden
cd /

# Ordner finden
for f in $( ls $path); do

# SQL-Dateien finden
	for g in $( ls $path$f | grep sql); do

# Dateien kopieren
		cp $path$f/$g $temp
	done
done

#Datum erstellen
datum=$(date +"%d"."%m"."%y")

#Dateien zusammenpacken und komprimieren
tar cfvz backup-sql-$datum.tar.gz $temp

#Verschlüsseln und gepackte Datei löschen
openssl aes-256-cbc -kfile $encryption -in backup-sql-$datum.tar.gz -out ./backup-sql-$datum.enc.tar.gz

rm backup-sql-$datum.tar.gz

#Kopieren und verschlüsselte Datei löschen
scp -i /etc/ssh/ssh_host_dsa_key ./backup-sql-$datum.enc.tar.gz $external:/mnt/usb/backups

rm backup-sql-$datum.enc.tar.gz

rm -r $temp
mkdir $temp
