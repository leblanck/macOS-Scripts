#!/bin/bash
#####################################
#   KL 9/14/2020                    #
#                                   #
#   Script for uninstalling Code42  #
#   on LMI macOS devices            #
#####################################

loggedInUser=$(stat -f %Su /dev/console)
systemPath="/Library/Application Support/CrashPlan/"
userPath="/Users/$loggedInUser/Library/Application Support/CrashPlan/"
AppPath="/Applications/CrashPlan.app"

echo "===== User is: "$loggedInUser
echo "===== System path is:" $systemPath
echo "===== User path is:" $userPath
echo "========================"
echo "== Starting Uninstall =="
echo "========================"

if [[ -d "$systemPath" ]]; then
    echo "===== System path found; Removing files..."
    launchctl unload /Library/LaunchDaemons/com.crashplan.engine.plist
    sudo chmod -R 755 "/Library/Application Support/CrashPlan/" 
    rm -r "$systemPath"
    rm -f /Library/LaunchDaemons/com.crashplan.engine.plist
    rm -r /Library/Caches/CrashPlan
    rm -rf /Library/Logs/CrashPlan
else
    echo "===== System Path NOT FOUND"
fi

if [[ -d "$userPath" ]]; then
    echo "===== User path found; Removing files..."
    launchctl unload /Users/$loggedInUser/Library/LaunchAgents/com.code42.menubar.plist
    rm -r "/Users/$loggedInUser/Library/Application Support/CrashPlan/"
    rm -r /Users/$loggedInUser/Library/Logs/CrashPlan/
    rm -r /Users/$loggedInUser/Library/Caches/CrashPlan/
else
    echo "===== User path NOT FOUND"
fi

if [[ -d "$AppPath" ]]; then
    echo "===== Removing CrashPlan.app..."
    sudo chflags noschg /Applications/CrashPlan.app
    rm -rf /Applications/CrashPlan.app
else
    echo "===== Crashplan App NOT FOUND in:" $AppPath
fi
