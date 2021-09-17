#!/bin/bash
######################################
#   KL 9/15/2020                     #
#                                    #
#   Used to swap out Code42 in favor #
#`   of MS OneDrive`                 #
######################################

loggedInUser=$(stat -f %Su /dev/console)
systemPath="/Library/Application Support/CrashPlan/"
userPath="/Users/$loggedInUser/Library/Application Support/CrashPlan/"
CPappPath="/Applications/CrashPlan.app"
LMNotifier="/Applications/Utilities/LM Notifier.app"
ODappPath="/Applications/OneDrive.app"
appPath="/Applications/CrashPlan.app"


launchLMNotifier() {
    if [[ ! -d "$LMNotifier" ]]; then
        echo "LMNotifier not found; Installing..."
        jamf policy -event lm-notifier-install
        sleep 10
        echo "Issuing Alert..."
        /Applications/Utilities/LM\ Notifier.app/Contents/MacOS/LM\ Notifier --type alert --title "CrashPlan is Being Uninstalled" --subtitle "OneDrive is replacing CrashPlan" --message "as the standard backup solution" --messagebutton "Learn More" --messagebuttonaction "https://myconnections.lmig.com/groups/mac-community-support/blog/2020/09/08/microsoft-onedrive-to-replace-code42"
    else
        echo "LMNotifier Installed; Issuing Alert..."
        /Applications/Utilities/LM\ Notifier.app/Contents/MacOS/LM\ Notifier --type alert --title "CrashPlan is Being Uninstalled" --subtitle "OneDrive is replacing CrashPlan" --message "as the standard backup solution" --messagebutton "Learn More" --messagebuttonaction "https://myconnections.lmig.com/groups/mac-community-support/blog/2020/09/08/microsoft-onedrive-to-replace-code42"
    fi
}

removeCode42() {
    if [[ -d "$systemPath" ]]; then
        echo "===== System path found; Removing files..."
        /Library/Application\ Support/CrashPlan/Uninstall.app/Contents/Resources/uninstall.sh
    else
        echo "===== "$systemPath" NOT FOUND"
    fi

    if [[ -d "$appPath" ]]; then
        sudo chflags -R noschg /Applications/CrashPlan.app
        sudo rm -rf /Applications/CrashPlan.app
    else
        echo "===== Application not found in:" $appPath
    fi
}

installOneDrive() {
    if [[ ! -d "$ODappPath" ]]; then
        echo "===== OneDrive not found; Installing..."
        jamf policy -event install-onedrive
    else
        echo "===== OneDrive is already installed; Exiting;"
    fi
}


launchLMNotifier
removeCode42
installOneDrive
jamf recon
