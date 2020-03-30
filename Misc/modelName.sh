#!/bin/bash
##########################
# Retreive Model Name from
# macOS machines.
# ex. Macbook Air (Early 2015)
#
# KL 9/7/2018
#########################

echo "Please enter desired Mac Model (ex. MacBookAir7,2):"

read modelID

#modelID="MacBookAir7,2"
defaults read /System/Library/PrivateFrameworks/ServerInformation.framework/Versions/A/Resources/English.lproj/SIMachineAttributes.plist "$modelID" | grep marketingModel | sed 's/;$//;s/^"//;s/"$//;s/\\//g' | awk '{print $4,$5,$6,$7}'
