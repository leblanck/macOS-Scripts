#!/usr/bin/env bash
############################################
# Post-Install script for the purpose      #
#   of setting up Zscaler client on macOS  #
#                                          #
#     USE FOR ZSCALER VERSION 2.1 ONLY     #
#                                          #
#   KL - 3/17/2020                         #
############################################

#SET VARS
cloudName="dump cloud name here"
userDomain="user domain here"
hideAppUI="1"
policyToken="1234567890"
unattendMode="none"
appLoc="/tmp/Zscaler-osx-2.1.0.190-installer.app"

#@@@@@@@@ MAIN @@@@@@@@@
#@  Don't edit below this line
#@  change Vars above to adjust the installer
#@@@@@@@@@@@@@@@@@@@@@@@

if [ -d $appLoc ]; then
     echo "Zscaler Installer found; Continuing..."
     echo "Installing Zscaler with Config..."
     sudo sh $appLoc/Contents/MacOS/installbuilder.sh --cloudName $cloudName --hideAppUIOnLaunch $hideAppUI --policyToken $policyToken --unattendedmodeui $unattendMode --userDomain $userDomain
else
    echo "Installer NOT found!!; Exiting..."
    exit 0
fi
