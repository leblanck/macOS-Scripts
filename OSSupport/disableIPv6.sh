#!/bin/bash
#####################################
#   KL 01/11/21                     #
#                                   #
#   Function to disable IPv6        #
#                                   #
#   Intended to be distributed      #
#   via Jamf                        #
#####################################

logAction() {
    #Set up logging
	logTime=$(date "+%Y-%m-%d - %H:%M:%S:")
	echo "$logTime" "$1" >> /var/log/IPv6Disable.log
}

TurnIPv6OFF() {
    #Log action then turn IPv6 off
    logAction "Turning IPv6 OFF for $1"
    networksetup -setv6off "$1"
}

CheckStatus() {
    #Check if IPv6 is set to Off or set to Automatic
    #If == Automatic or Manual then route to TurnIPv6OFF func
    v6status=$(networksetup -getinfo "$1" | grep IPv6: | awk '{print $2}')
    logAction "IPv6 Status of $1 is: $v6status"

    if [ $v6status = "Automatic" ] || [ $v6status = "Manual" ]; then
        TurnIPv6OFF "$1" 
    elif [ $v6status = "Off" ]; then
        logAction "IPv6 is already turned off for $1"
    else
        logAction "Something went wrong; Printing v6Status:"
        logAction "Status: $v6status"
        logAction "Something went wrong; Printing v6Status:"
        exit 1
    fi
}

GetNetworkServices() {
    #List all network services (Wi-Fi, Ethernet, etc), remove title line, loop over results and pass to CheckStatus function
    networksetup -listallnetworkservices | tail -n +2 | while read line; do CheckStatus "$line"; done
}

## MAIN ##
GetNetworkServices
