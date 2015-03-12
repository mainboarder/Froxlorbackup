Froxlorbackup
=============

Backup your Froxlor Webhosting (or anything else) to another server. Encrypted, via ssh.

Works for all versions.

0. install duplicity and all required packages
1. copy the script to the froxlorserver and run it as `/$PATH/backup-server.sh full`
2. Add a cronjob like `17 2 * * * /$PATH/backup-server.sh`
3. Let the magic happen

You can restore your data with
`duplicity -t nD --file-to-restore relative/neddedFile $EXTERNALPATH/TO//media/mount/duplicity/ /where/to/save/now`

| Parameter | Description|
| ------------- | ------------- |
| `-t nD` | The version from how much days in the past should be recovered? |
| `relative/neddedFile` | Where, relative from the next parameter is the file in the backup? |
| `$EXTERNALPATH/TO//media/mount/duplicity/` | Where are the duplicity-files stored on the external storage? |
| `/where/to/save/now` | Where should the recovered file saved to (must not exist)? |

Example:
`duplicity -t 8D --file-to-restore apache2/sites-available/site.conf ssh://backup@hostname2.domain.tld//home/hostname1/etc /home/user/site.conf`

If you execute this on the machine where you want to restore an eight days old `/etc/apache2/sites-available/site.conf` from the external machine `hostname2.domain.tld`, then the recovered file will be saved in `/home/user/site.conf`
