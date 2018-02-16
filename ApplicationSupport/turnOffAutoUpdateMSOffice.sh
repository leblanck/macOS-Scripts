#!/bin/bash
########################
# Change MS Office     #
# Updates from Auto    #
# to Manual to prevent #
# popups               #
########################

userName=$(defaults read /Library/Preferences/com.apple.loginwindow.plist lastUserName)
defaults write /Users/$userName/Library/Preferences/com.microsoft.autoupdate2.plist HowToCheck Manual
defaults write /Users/$userName/Library/Preferences/com.microsoft.autoupdate2.plist StartDaemonOnAppLaunch NO
chmod 744 /Users/$userName/Library/Preferences/com.microsoft.autoupdate2.plist
