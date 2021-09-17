#!/bin/zsh

# This is an extension attribute script to report CrashPlan status
# There are 4 possible values with definitions below:
# On, Logged In: ${CrashPlanUser}:
#   Application is running and user is logged in
# On, Not Logged In:
#   Application is running but user is not logged in
# Off:
#   Application is not running
# Not Installed:
#   CrashPlan Is Not Installed

# CrashPlan Application Path
CrashPlanPath="/Applications/CrashPlan.app"

# Check if CrashPlan is installed before anything else
if [[ ! -d "$CrashPlanPath" ]]; then
    echo "<result>Not Installed</result>"
    exit 0
fi

# Sets value of CrashPlan Application Log
CrashPlanAppLog="/Library/Logs/CrashPlan/app.log"

#If value is 0, no user is logged in to CrashPlan
CrashPlanLoggedIn="$(/usr/bin/awk '/USER/{getline; gsub("\,",""); print $1; exit }' $CrashPlanAppLog)"

# Gets CrashPlan username
CrashPlanUser="$(/usr/bin/awk '/USER/{getline; gsub("\,",""); print $2; exit }' $CrashPlanAppLog)"

# Checks if Code42 Client is Running
CrashPlanRunning="$(/usr/bin/pgrep "CrashPlan")"


# Reports CrashPlan Status and Username
if [[ -n "${CrashPlanRunning}" ]]; then
    CrashPlanStatus="On, "
    if [[ "${CrashPlanLoggedIn}" -eq 0 ]]
    then
        CrashPlanStatus+="Not Logged In"
    else
        CrashPlanStatus+="Logged In: ${CrashPlanUser}"
    fi
else
    CrashPlanStatus="Off"
fi

echo "<result>${CrashPlanStatus}</result>"
