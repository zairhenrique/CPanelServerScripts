# CPanelServerScripts
A collection of scripts to use on cPanel servers that I've wrote/modified.

## disablebackup.sh
This script check for accounts with more than MAXINODES inodes and/or greather than MAXSIZE and disable the cPanel automatic backup. This prevents that the backup breaks with giant accounts, so you can handle these in another manner.

## inodenotifier.sh
This script checks for accounts with more than  "$inodes" inodes and notify or do any action you want with these. quota system needs to be active on /home, as this scripts use repquota to get inode usage.
