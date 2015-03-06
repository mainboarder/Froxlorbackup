Froxlorbackup
=============

Backup your Froxlor Webhosting (or anything else) to another server. Encrypted, via ssh.

Works for all versions.

0. install duplicity and all required packages
1. copy the script to the froxlorserver and run it as `/$PATH/backup-server.sh full`
2. Add a cronjob like `17 2 * * * /$PATH/backup-server.sh`
3. Let the magic happen

You can restore your data with
`duplicity --file-to-restore neddedFile $EXTERNALPATH/TO//media/mount/duplicity/path/to/file/ /where/to/save/now`
