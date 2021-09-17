#!/bin/bash

# First check, if Mojave has been downloaded already. If so, delete the setup app.
file="/Applications/Install macOS Mojave.app"
if [ -d "$file" ]
then
    rm -R /Applications/Install\ macOS\ Mojave.app
    echo "Mojave deleted."
else
    echo "Mojave not found."
fi

# Deactivate automatic OS update downloads
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticDownload -bool NO
echo "Automatic OS Update downloads deactivated."

exit 0
