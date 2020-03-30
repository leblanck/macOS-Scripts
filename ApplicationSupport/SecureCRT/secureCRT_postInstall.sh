#!/usr/bin/env bash
############################### 
# Postinstaller for SecureCRT #
#    v8.5. Sets .lic file for #
#    licensed user            #
###############################
# Kyle LeBlanc                #
# Last Edit: 2/24/2020        #
###############################

## Set Vars
loggedInUser=$(stat -f %Su /dev/console)
appName=/Applications/SecureCRT.app
licenseFile=/Users/$loggedInUser/Library/Application\ Support/VanDyke/SecureCRT/Config/SecureCRT.lic
licenseDir=/Users/$loggedInUser/Library/Application\ Support/VanDyke/SecureCRT/Config/
tmpInstallFiles=/tmp/SecureCRT

installLicense() {
    if [ -d $tmpInstallFiles ]; then
        echo "License files found; Moving..."
        if [ -d "$licenseDir" ]; then
            mv /tmp/SecureCRT/SecureCRT.lic "$licenseDir"
        else
            echo "Creating necessary directories..."
            mkdir /Users/$loggedInUser/Library/Application\ Support/VanDyke
            mkdir /Users/$loggedInUser/Library/Application\ Support/VanDyke/SecureCRT
            mkdir "$licenseDir"
            echo "Moving license file..."
            mv $tmpInstallFiles/SecureCRT.lic "$licenseDir"
        fi
    else
        echo "License NOT Found!!; Exiting..."
        exit 0
    fi
}

removeLicense() {
    rm $licenseFile
    installLicense
}

setPerms() {
    echo "Setting user permissions for license file..."
    chown -R $loggedInUser:staff Users/$loggedInUser/Library/Application\ Support/VanDyke
}

main() {
    if [ -d $appName ]; then
        echo "Application found; Continuing..."
        if [ -f "$licenseFile" ]; then
            echo "License found; Removing and replacing..."
            removeLicense
        else
            echo "No existing license found; Continuing..."
            installLicense
        fi
        setPerms
        echo "Done!"
    else
        echo "Application not found; Exiting..."
        exit 0
    fi
}

main
