#!/bin/sh

###########
# Logging #
###########
LogFile="/Library/Logs/jssMoveDomains.log"
if [[ ! -e $LogFile ]]; then
    touch $LogFile && exec >> $LogFile
    echo "`date` ========== Log File Created"
else
    exec >> $LogFile
fi

######################
# User Communication #
######################
## Change the dialog to what you want to tell your users
echo "`date` ========== Banner Posted to User"
banner=`/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType hud -title "Wayfair Domain Migration" -heading "Wayfair Domain Migration" -description "Your Mac is now being migrated to the new Wayfair Corp domain. After this window closes, you will be logged out of your computer within ~2 minutes. Pleaes log back in and you will be prompted to change your password for the new domain. Next, your machine will reboot. Please log in normally and contact IT Service Desk with any issues" -icon /Users/Shared/ITS/wayfair.png -button1 "Proceed" -defaultButton 1 -timeout 60 -countdown`
#
if [[ $banner == "2" ]]; then
     echo "User canceled the move."
     exit 1
fi

####################
# Casper Variables #
####################
# 1=mount point ## Defined by Casper ##
# 2=computer name ## Defined by Casper ##
# 3=username ## Defined by Casper ##

### IF USING CASPER MAKE SURE TO ENTER VARIABLES AS PARAMETERS 4-9 IN POLICY ###
## IF NOT USING CASPER UNCOMMENT THESE LINES AND ENTER REQUIRED INFO ##

#4=oldAD                       ## Enter current Domain ex 'ad.company.com'
#5=newAD                       ## Enter New Domain ex 'domain.company.com'
#6=adminEmail                  ## Enter notification email address
#7=oldADAdmin                  ## Enter Network account with permission to remove computer from old domain
#8=oldADPass                   ## Enter Password for Network account with permission to remove computer from old domain
#9="JSS Bind Policy number"

####################
# Global Variables #
####################

oldAD=$4
newAD=$5
adminEmail=$6
oldADAdmin=$7
oldADPass=$8

echo "`date` ========== Getting Current AD and User Info"
#Get macOS version, current Active Directory domain, and Computer Name
osVersion=`sw_vers -productVersion | cut -d. -f1,2`
currentAD=`dsconfigad -show | grep -i "active directory domain" | awk '{ print $5 }'`
computerName=`scutil --get ComputerName`

## Obtain current logged in user ##
loggedInUser=`ls -l /dev/console | /usr/bin/awk '{ print $3 }'`

# Obtain current logged in users UniqueID
loggedInUserID=`dscl . read /Users/$loggedInUser UniqueID | awk '{ print $2 }'`

## User's home folder location
userHome=`dscl . read /Users/$loggedInUser NFSHomeDirectory | awk '{ print $2 }'`

echo "`date` ========== Remove User From FV"
#Remove user from FileVault
fdesetup remove -user "$loggedInUser"

##################
# Unbind from AD #
##################
# check to see if we are bound to our current AD or not.  If not we can skip this

if [[ "$currentAD" = "$oldAD" ]]; then
    # remove the config for our old AD
    echo "`date` ========== Unbinding from ZOO"
    dsconfigad -remove "$oldAD" -force -user "$oldADAdmin" -password "$oldADPass"
fi

##################
# Bind to new AD #
##################

## using a JAMF policy ##
echo "`date` ========== Binding to CORP"
jamf policy -event bind_boston_corp
sleep 5

### verify that the move was successful
checkAD=`dsconfigad -show | grep -i "active directory domain" | awk '{ print $5 }'`

if [[ "$checkAD" != "$newAD" ]]; then
    echo "`date` ========== BINDING FAILED - EMAIL SENT"
    #####  SEND AN EMAIL TO THE ADMIN  #####
    message1="$loggedInUser attempted to run the Domain Migration Policy on $computerName and it failed to bind to $newAD."
    echo "$message1" | mail -s "Domain Migration Policy Failure" "$adminEmail"
    exit 99
fi

#####################
# Reset Permissions #
#####################
echo "`date` ========== Resetting Permissions"
## Get the Active Directory Node Name
adNodeName=`dscl /Search read /Groups/Domain\ Users | awk '/^AppleMetaNodeLocation:/,/^AppleMetaRecordName:/' | head -2 | tail -1 | cut -c 2-`
## Get the Domain Users groups Numeric ID
domainUsersPrimaryGroupID=`dscl /Search read /Groups/Domain\ Users | grep PrimaryGroupID | awk '{ print $2}'`
#Get Users UniqueID
accountUniqueID=`dscl "$adNodeName" -read /Users/$loggedInUser 2>/dev/null | grep UniqueID | awk '{ print $2}'`
#change old UID for new UID
dscl . -change /Users/$loggedInUser UniqueID "$loggedInUserID" "$accountUniqueID"
#chown home folder ownership for new UID/GID
chown -R $loggedInUser:$domainUsersPrimaryGroupID /Users/$loggedInUser

#Recon machine to JSS
echo "`date` ========== Running Recon"
jamf recon

#####  SEND AN EMAIL TO THE ADMIN  #####
echo "`date` ========== SUCCESS - EMAIL SENT"
message2="$loggedInUser successfully ran the Domain Migration Policy on $computerName and it is now joined to $newAD."
echo "$message2" | mail -s "Domain Migration Policy Success" $adminEmail

echo "`date` ========== Remove AD Cache Files"
#Remove cached AD Files
rm -f /var/db/dslocal/nodes/Default/sqlindex*
mv /var/db/dslocal/nodes/Default/users/"$loggedInUser".plist /var/db/dslocal/nodes/Default/users/"$loggedInUser".OLD

#echo "`date` ========== Setup authrestart"
# create the plist file:
#echo '<?xml version="1.0" encoding="UTF-8"?>
#<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
#<plist version="1.0">
#<dict>
#<key>Password</key>
#<string>FVEnabledPassword</string>
#</dict>
#</plist>' > /tmp/authrestart.plist

#perform authenticated reboot
echo "`date` ========== REBOOTING"
#fdesetup authrestart -inputplist < /tmp/authrestart.plist

/Users/Shared/ITS/FV2authRestart.sh

