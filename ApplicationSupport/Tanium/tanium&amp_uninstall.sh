#!/bin/bash

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
     echo "Not running as root or using sudo"
     exit
fi

#Remove Tanium
launchctl unload /Library/LaunchDaemons/com.tanium.taniumclient.plist
launchctl remove com.tanium.taniumclient > /dev/null 2>&1
rm /Library/LaunchDaemons/com.tanium.taniumclient.plist
rm /Library/LaunchDaemons/com.tanium.trace.recorder.plist
rm -rf /Library/Tanium/
rm /var/db/receipts/com.tanium.taniumclient.TaniumClient.pkg.bom3
rm /var/db/receipts/com.tanium.taniumclient.TaniumClient.pkg.plist


#Remove AMP
/usr/sbin/installer -verbose -pkg /Applications/Cisco\ AMP\ for\ Endpoints/Uninstall\ AMP\ for\ Endpoints\ Connector.pkg -target /
