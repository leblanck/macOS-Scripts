#!/bin/sh

# NOTE: you may want to turn off logging so that no passwords are captured.
###########
# Logging #
###########

LOGPATH='/Library/Logs'               # change this line to point to your local logging directory
if [[ ! -d "$LOGPATH" ]]; then
    mkdir $LOGPATH
fi
set -xv; exec 1> $LOGPATH/jssMoveDomains.log 2>&1  # you can name the log file what you want
version=1.2

######################
# User Communication #
######################

## Change the dialog to what you want to tell your users
## Casper Version ##
#
banner=`/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType hud -title "Wayfair Domain Migration" -heading "Wayfair Domain Migration" -description "Your Mac is now being migrated to the new Wayfair Corp domain. After this window closes, you will be logged out of your computer within ~2 minutes. Pleaes log back in and you will be prompted to change your password for the new domain. Next, your machine will reboot. Please log in normally and contact IT Service Desk with any issues" -icon /Users/Shared/ITS/wayfair.png -button1 "Proceed" -defaultButton 1 -timeout 60 -countdown`
#
if [[ $banner == "2" ]]; then
     echo "User canceled the move."
     exit 1
fi

## AppleScript version ##
#
#banner=$(osascript -e 'display dialog "We are moving your user account to the new authentication domain.  When we are completed, your computer will restart and you can use your new account information." buttons {"Cancel", "Migrate"} default button "Migrate" with title "Moving Domains" with icon 2')
#
#if [[ $banner != "button returned:Migrate" ]]; then
#     echo "User canceled the move."
#    exit 1
#fi

####################
# Casper Variables #
####################
# 1=mount point ## Defined by Casper ##
# 2=computer name ## Defined by Casper ##
# 3=username ## Defined by Casper ##

### IF USING CASPER MAKE SURE TO ENTER VARIABLES AS PARAMETERS 4-9 IN POLICY ###
## IF NOT USING CASPER UNCOMMENT THESE LINES AND ENTER REQUIRED INFO ##

4=oldAD                       ## Enter current Domain ex 'ad.company.com'
5=newAD                ## Enter New Domain ex 'domain.company.com'
6=adminEmail          ## Enter notification email address
7=oldADAdmin                 ## Enter Network account with permission to remove computer from old domain
8=oldADPass                  ## Enter Password for Network account with permission to remove computer from old domain
#9="JSS Bind Policy number"

####################
# Global Variables #
####################

oldAD=$4
newAD=$5
adminEmail=$6
oldADAdmin=$7
oldADPass=$8

osVersion=`sw_vers -productVersion | cut -d. -f1,2`
currentAD=`dsconfigad -show | grep -i "active directory domain" | awk '{ print $5 }'`
computerName=`scutil --get ComputerName`

## Obtain current logged in user ##
loggedInUser=`ls -l /dev/console | /usr/bin/awk '{ print $3 }'`

# Obtain current logged in users UniqueID
loggedInUserID=`dscl . read /Users/$loggedInUser UniqueID | awk '{ print $2 }'`

## User's home folder location
userHome=`dscl . read /Users/$loggedInUser NFSHomeDirectory | awk '{ print $2 }'`

#Remove user from FileVault
fdesetup remove -user "$loggedInUser"

## Use these if binding to new AD via script instead of Casper Policy ##
#newADAdmin="a-kleblanc"                   ## Enter Network account with permission to join computer to new domain
#newADPass="Whereisthed0g?"                    ## Enter Password for Network account with permission to join computer to new domain
#newDomainOU="OU=Office,OU=Workstations,OU=Wayfair,DC=corp,DC=wayfair,DC=com"  ## Enter container that you want computers joined to
#newDomainGroup="group"              ## Enter group that you want added to Admin bound Macs
### ### ### ### ###

##################
# Unbind from AD #
##################
# check to see if we are bound to our current AD or not.  If not we can skip this

if [[ "$currentAD" = "$oldAD" ]]; then
    # remove the config for our old AD
    dsconfigad -remove "$oldAD" -force -user "$oldADAdmin" -password "$oldADPass"
fi

##################
# Bind to new AD #
##################

## using a JAMF policy ##
jamf policy -event bind_boston_corp
sleep 5

## using "dsconfigad" ##
#dsconfigad -add "$newAD" -username "$newADAdmin" -password "$newADPass" -computer "$computerName" -ou "$newDomainOU" -force
#sleep 5
#
#dsconfigad -groups "$newDomainGroup" -localhome enable -mobile enable -mobileconfirm disable -useuncpath disable
#
#dsconfigad -localhome enable -mobile enable -mobileconfirm disable -useuncpath disable
#sleep 5
#
#dsconfigad -passinterval 30
#sleep 5


### verify that the move was successful
checkAD=`dsconfigad -show | grep -i "active directory domain" | awk '{ print $5 }'`

if [[ "$checkAD" != "$newAD" ]]; then
    echo "SOMETHING WENT WRONG AND WE ARE NOT BOUND"
    #####  SEND AN EMAIL TO THE ADMIN  #####
    message1="$loggedInUser attempted to run the Domain Migration Policy on $computerName and it failed to bind to $newAD."
    echo "$message1" | mail -s "Domain Migration Policy Failure" "$adminEmail"
    exit 99
fi

#####################
# Reset Permissions #
#####################

### Because we are not deleting the user account, FileVault enabled users will still be able to unlock the drive.
### However, if the users password is different from the old domain to the new domain, the user will need to use their old password at the FV screen.
### They will then be placed at the login screen and when entering the new password will be prompted to sync the keychain and FV password.

## Get the Active Directory Node Name

adNodeName=`dscl /Search read /Groups/Domain\ Users | awk '/^AppleMetaNodeLocation:/,/^AppleMetaRecordName:/' | head -2 | tail -1 | cut -c 2-`

## Get the Domain Users groups Numeric ID

domainUsersPrimaryGroupID=`dscl /Search read /Groups/Domain\ Users | grep PrimaryGroupID | awk '{ print $2}'`

accountUniqueID=`dscl "$adNodeName" -read /Users/$loggedInUser 2>/dev/null | grep UniqueID | awk '{ print $2}'`

dscl . -change /Users/$loggedInUser UniqueID "$loggedInUserID" "$accountUniqueID"

chown -R $accountUniqueID:$domainUsersPrimaryGroupID /Users/$loggedInUser

#####  SEND AN EMAIL TO THE ADMIN  #####
message2="$loggedInUser successfully ran the Domain Migration Policy on $computerName and it is now joined to $newAD."
echo "$message2" | mail -s "Domain Migration Policy Success" $adminEmail


#Recon machine to JSS
jamf recon

#Remove cached AD Files
rm -f /var/db/dslocal/nodes/Default/sqlindex*
mv /var/db/dslocal/nodes/Default/users/"$loggedInUser".plist /var/db/dslocal/nodes/Default/users/"$loggedInUser".OLD


#Logout User
pkill loginwindow
