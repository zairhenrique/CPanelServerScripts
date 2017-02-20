#!/bin/bash

MAXINODES=100000
MAXSIZE=5242880

disablebackup () {
	# Check if new backup is active.
	if [ `/usr/sbin/whmapi1 accountsummary user="$1" | grep -Po "(?<= backup: )([0-1])"` -eq 1 ]
	then
		/usr/sbin/whmapi1 toggle_user_backup_state user="$1" legacy=0
	fi
	
	# Check if legacy backup is active.
	if [ `/usr/sbin/whmapi1 accountsummary user="$1" | grep -Po "(?<= legacy_backup: )([0-1])"` -eq 1 ]
	then
		/usr/sbin/whmapi1 toggle_user_backup_state user="$1" legacy=1
	fi
}

enablebackup () {
	# Check if new backup is active.
	if [ `/usr/sbin/whmapi1 accountsummary user="$1" | grep -Po "(?<= backup: )([0-1])"` -eq 0 ]
	then
		/usr/sbin/whmapi1 toggle_user_backup_state user="$1" legacy=0
	fi
	
	# Check if legacy backup is active.
	if [ `/usr/sbin/whmapi1 accountsummary user="$1" | grep -Po "(?<= legacy_backup: )([0-1])"` -eq 0 ]
	then
		/usr/sbin/whmapi1 toggle_user_backup_state user="$1" legacy=1
	fi

}


users=$(cat /etc/trueuserowners | grep -v ^# | cut -d: -f1)

for user in $users
do
	enablebackup $user
done

for i in $(repquota /home | tail -n +6 |grep ^[a-Z] | awk '{ print $1 "|" $3 "|" $6 }')
do

        user=$(cut -d "|" -f 1 <<< $i)
        dused=$(cut -d "|" -f 2 <<< $i)
        inode=$(cut -d "|" -f 3 <<< $i)

        if [ $inode == "none" ]
        then
                inode=0
        fi

        if [ ${inode} -gt ${MAXINODES} -o ${dused} -gt ${MAXSIZE} ]
        then
                disablebackup $user

        fi
done
