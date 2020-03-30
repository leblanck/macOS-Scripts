#!/usr/bin/env bash
############################################
# Post-Install script for the purpose      #
#   of setting up Tanium client on macOS   #
#                                          #
#   KL - 2/5/2020                          #
############################################

##Set Vars
serverName="Enter your Tanium Prod server Here"


cd /tmp/ || exit 0
echo "Mounting Tanium Installer"
hdiutil mount PROD-Mac-TaniumClient-7.2.314.3608.iso

cd /Volumes/TaniumClient/ || exit 0
echo "Installing Tanium..."
installer -pkg TaniumClient-7.2.314.3608.pkg -target /

newVer="7.2.314.3608"

if [[ -a /Library/Tanium/TaniumClient/TaniumClient ]]; then
        version=$(/Library/Tanium/TaniumClient/TaniumClient -v)
        if [[ "$version" == "$newVer" ]]; then
                echo "Update succesfull. Installed version: ${version}" 
            else
                echo "Update failed. Version ${version} is still installed"
        fi
    else
        echo "Tanium not found; Exiting"
        exit 0
fi

echo "Setting Tanium Server Name"
/Library/Tanium/TaniumClient/TaniumClient config set ServerName $serverName

echo "Reloading Tanium Launchd"
launchctl unload /Library/LaunchDaemons/com.tanium.taniumclient.plist
launchctl load /Library/LaunchDaemons/com.tanium.taniumclient.plist

echo "Unmounting Tanium Installer"
cd /tmp/ || exit 0
hdiutil unmount /Volumes/TaniumClient

echo "Cleaning Up Installer"
rm -f PROD-Mac-TaniumClient-7.2.314.3608.iso
