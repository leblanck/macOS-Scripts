#!/bin/bash
#####################################
#   KL 12/09/19                     #
#                                   #
#   Post-Install setup for Firefox  #
#   for LMI standards               #
#####################################

#Enable the ability to defaults write FF settings
defaults write /Library/Preferences/org.mozilla.firefox EnterprisePoliciesEnabled -bool TRUE

#Set EntperiseRoots to True by default
defaults write /Library/Preferences/org.mozilla.firefox Certificates__ImportEnterpriseRoots -bool TRUE

#Set Homepage to myLiberty and lock it 
defaults write /Library/Preferences/org.mozilla.firefox Homepage__URL -string "https://mylibertyhome.lmig.com/"
defaults write /Library/Preferences/org.mozilla.firefox Homepage__Locked -bool FALSE

#Set pop-ups whitelist
#defaults write /Library/Preferences/org.mozilla.firefox PopupBlocking__Allow -array "https://myliberty.lmig.com/" "https://mylibertyhome.lmig.com/"
defaults write /Library/Preferences/org.mozilla.firefox PopupBlocking__Allow -array "'[*.]lmig.com'"
defaults write /Library/Preferences/org.mozilla.firefox PopupBlocking__Locked -bool FALSE

