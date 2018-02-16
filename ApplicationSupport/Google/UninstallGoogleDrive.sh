#!/bin/bash

#Get Logged in Users
userName=$(defaults read /Library/Preferences/com.apple.loginwindow.plist lastUserName)

#Uninstall Google Drive App
rm -rf /Applications/Google\ Drive.app/

#Sleep for 10 SECONDS
sleep 10

#kill google drive process
ps aux | grep -i google | awk {'print $2'} | xargs kill -9

#Remove Logged in User's Google Drive folder
rm -rf /Users/$userName/Google\ Drive/
