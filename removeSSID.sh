#!/bin/bash

#####################################
# Used to removed SSID from         #
# Netowrk Preferences when option   #
# is locked down from standard user #
#####################################
# USAGE: Replace #FIXED_SSID with   #
# your own custom SSID that you want#
# as a permanent option for the user#
# to see                            #
#####################################
# Kyle LeBlanc                      #
# Last Edit: 3/21/17                #
#####################################

KIND=$(osascript <<-EOF

tell application "Finder"
  set answer to choose from list {"Personal WiFi", "#FIXED_SSID"}
  if answer is false then
    return "Cancel" as text
  else if answer contains "Personal WiFi" then
    return "Personal WiFi" as text
  else
    return "#FIXED_SSID" as text
  end if
end tell
EOF)

if [ "$KIND" == "Personal WiFi" ]; then

  SSID=$(osascript <<-EOF

  tell application "Finder"
    set theSSID to display dialog "Enter WiFi Network:" default answer ""
    end tell

    text returned of theSSID

EOF)
  networksetup -removepreferredwirelessnetwork en0 $SSID
else
  networksetup -removepreferredwirelessnetwork en0 #FIXED_SSID
fi
