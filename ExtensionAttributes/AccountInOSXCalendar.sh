#!/bin/bash

#Get Logged in Users
userName=$(defaults read /Library/Preferences/com.apple.loginwindow.plist lastUserName)
echo $userName

calContents=$(ls /Users/$userName/Library/Calendars)

echo $calContents
size=${#calContents}

if [[ "$size" -gt "1" ]]; then
  echo "<result>Account Enabled in macOS Calendars</result>"
else
  echo "<result>No Account found in macOS Calendars</result>"
fi
