#!/bin/bash
##################################
# Google Chrome Updater          #
#  Replace $4 in JSS with        #
#  updated ver number            #
##################################
# Kyle LeBlanc                   #
# Last Edit: 07/02/2019          #
##################################


chromeURL="https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg"
chromePath="/tmp/GoogleChrome.dmg"
#updatedVer="75.0.3770.100"
updatedVer="$4" #Set the current version in Jamf Parameter 4

cleanUp() {
    echo "`date` ========== Unmounting DMG =========="
    hdiutil detach /Volumes/Google\ Chrome -quiet
    echo "`date` ========== Deleting DMG =========="
    rm -f ${chromePath}
    echo "`date` ========== Done! =========="

}

installChrome() {
    echo "`date` ========== Mounting DMG =========="
    hdiutil attach ${chromePath} -nobrowse -quiet
    echo "`date` ========== Installing... =========="
    ditto -rsrc "/Volumes/Google Chrome/Google Chrome.app" "/Applications/Google Chrome.app"
    sleep 10
    cleanUp
}

downloadChrome() {
    echo "`date` ========== Downloading Google Chrome DMG =========="
    curl -L -o ${chromePath} ${chromeURL}
    installChrome
}

checkChrome() {
    echo "`date` ========== Getting Current Chrome Ver =========="
    currentVer=$(/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --version |  awk {'print $3'})
    echo "`date` ========== Current Installed Ver = ${currentVer} =========="

    if [[ ${currentVer} != ${updatedVer} ]]; then
        echo "`date` ========== Google Chrome is outdated; Updating from ${currentVer} to ${updatedVer} =========="
        downloadChrome
    else
        echo "`date` ========== Google Chrome is up-to-date; Congrats! =========="
    fi
}

estLogs() {
    # Setup log files if logs do not exists, create it, otherwise start logging
    LogFile="/Library/Logs/GCUpdater.log"
    if [[ ! -e ${LogFile} ]]; then
        touch ${LogFile} && exec >> ${LogFile}
        echo "`date` ========== Log File Created =========="
    else
        exec >> ${LogFile}
    fi
}

estLogs
checkChrome

exit 0
