#!/bin/bash

#Get Logged in Users
userName=$(defaults read /Library/Preferences/com.apple.loginwindow.plist lastUserName)
echo $userName

mailContents=$(ls /Users/$userName/Library/Mail)

echo $mailContents
size=${#mailContents}

if [[ "$size" -gt "1" ]]; then
  echo "<result>Account Enabled in macOS Mail</result>"
else
  echo "<result>No Account found in macOS Mail</result>"
fi
