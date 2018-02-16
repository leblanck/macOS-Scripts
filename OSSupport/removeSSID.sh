#!/bin/bash

KIND=$(osascript <<-EOF

tell application "Finder"
  set answer to choose from list {"Personal WiFi", "WayFi"}
  if answer is false then
    return "Cancel" as text
  else if answer contains "Personal WiFi" then
    return "Personal WiFi" as text
  else
    return "WayFi" as text
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
  networksetup -removepreferredwirelessnetwork en0 WayFi
fi
