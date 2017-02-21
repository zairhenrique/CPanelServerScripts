#!/bin/bash

###########
#
#  This script checks for accounts with more than
#  "$inodes" inodes and notify or do any action
#  you want with these. quota system needs to be
#  active on /home, as this scripts use repquota
#  to get inode usage.
#
###########



# List of users to exclude from the check.
exclude="root\|hserv"


server=$(hostname)
list=$(repquota /home | grep -v "$exclude" | awk 'NR>5 {print $0}')
fulldate=$(date +"%d-%m-%Y")

# File to store log of notified accounts.
lognotified="/tmp/inodenotified.log"
IFS=$'\n'

# Minimum number of inodes to get notified.
inodes=250000

if ! grep "$fulldate" "$lognotified" 2>&1> /dev/null
then
    echo "Notified in $fulldate" >> $lognotified
fi


for line in $list
do
        signal=$(echo $line | awk '{print $2}')
        if [ "$signal" == "--" ]; then
                echo $line | awk -v inodes="$inodes" '$6>inodes {print $6 " " $1}' >> /tmp/inodelog.log
        elif [ "$signal" == "+-" ]; then
                echo $line | awk -v inodes="$inodes" '$7>inodes {print $7 " " $1}' >> /tmp/inodelog.log
        fi
done

while IFS= read -r line
do
        user=$(echo $line | awk '{print $2}')
        domain_line=$(cat /etc/trueuserdomains | cut -d: -f2 | grep -Fxn " $user" | cut -d: -f1)
        domain=$(cat /etc/trueuserdomains | awk -v domain_line="$domain_line" ' NR == domain_line ' | cut -d: -f1)
        owner_line=$(cat /etc/trueuserowners | cut -d: -f1 | grep -Fxn "$user" | cut -d: -f1)
        owner=$(cat /etc/trueuserowners | awk -v owner_line="$owner_line" ' NR == owner_line ' | cut -d: -f2 | xargs)

	## If you want to take actions on the account owner instead of the user itself, use this.
	## In case you want to take actions on the accounts even if it is inside a reseller, remove this
	## if statement.

        if [ $owner != "root" ]; then
            user=$owner
        fi

        ## Here you can put a cURL or other action to do with the accounts with more than $inodes, like a notification.

    echo "$line - $user - $domain" >> $lognotified

done < /tmp/inodelog.log

rm -f /tmp/inodelog.log
