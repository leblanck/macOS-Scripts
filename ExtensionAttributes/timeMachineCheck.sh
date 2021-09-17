#!/bin/bash

backupDate="Ext Attr Not Run"
plist="/Library/Preferences/com.apple.TimeMachine.plist"

backupCheck=$(defaults read "$plist" | awk '/AutoBackup/{print $3}' | tr -d ";")
if [ "$backupCheck" = "1" ]; then
    backupDate=$(defaults read "$plist" Destinations | sed -n '/SnapshotDates/,$p' | grep -e '[0-9]' | awk -F '"' '{print $2}' | sort | tail -n1 | cut -d" " -f1,2)
    if [ "$dateBackup" = "" ]; then
        backupDate="Initial Backup Incomplete"
    fi
elif [ "$backupCheck" = "0" ]; then
    backupDate="No Time Machine Backups - AutoBackup Disabled"
else
	backupDate="NULL"
fi

echo "<result>$backupDate</result>"
