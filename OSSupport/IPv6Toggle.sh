#!/bin/bash
#####################################
#   KL 11/25/19                     #
#                                   #
#   Function to toggle IPv6         #
#   either to automatic or off      #
#   depending on current state.     #
#                                   #
#   Intended to be distributed      #
#   via Jamf Self-Service           #
#####################################

logAction() {
    #Set up logging
	logTime=$(date "+%Y-%m-%d - %H:%M:%S:")
	echo "$logTime" "$1" >> /var/log/IPv6Toggle.log
}

TurnIPv6OFF() {
    #Log action then turn IPv6 off
    logAction "Turning IPv6 OFF for $1"
    networksetup -setv6off "$1"
}

TurnIPv6AUTO() {
    #Log action then turn IPv6 to Auto
    logAction "Turning IPv6 to AUTO for $1"
    networksetup -setv6automatic "$1"
}

CheckStatus() {
    #Check if IPv6 is set to Off or set to Automatic
    #If == Automatic then route to TurnIPv6OFF func
    #If == Off then route to TurnIPv6AUTO func
    v6status=$(networksetup -getinfo "$1" | grep IPv6: | awk '{print $2}')
    logAction "IPv6 Status of $1 is: $v6status"

    if [ $v6status = "Automatic" ]; then
        TurnIPv6OFF "$1"
    elif [ $v6status = "Off" ]; then
        TurnIPv6AUTO "$1"
    else
        logAction "No Status Found; Exiting"
        exit 1
    fi
}

GetNetworkServices() {
    #List all network services (Wi-Fi, Ethernet, etc), remove title line, loop over results and pass to CheckStatus function
    networksetup -listallnetworkservices | tail -n +2 | while read line; do CheckStatus "$line"; done
}

## MAIN ##
GetNetworkServices
