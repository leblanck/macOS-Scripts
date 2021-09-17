#!/usr/bin/env bash
############################### 
#Used to add device to single static group.
# static group should be assigned in Jamf Policy.
###############################
# Kyle LeBlanc                #
# Last Edit: 5/07/2020        #
###############################

## Set Vars
orgName=""
jamfURL=""
jamfAPIUser=""
jamfAPIEncPass=$(echo ${4}) #Called from Jamf
jamfAPISalt=""
jamfAPIPassPhrase=""
staticGroupID=$(echo ${5}) #Called from Jamf
staticGroupName=$(echo ${6}) #Called from Jamf
ComputerName=$(hostname)

DecryptString() {
		# Usage: ~$ DecryptString "Encrypted String" "Salt" "Passphrase"
		echo "${1}" | /usr/bin/openssl enc -aes256 -d -a -A -S "${2}" -k "${3}"  
}

assignDevice() {
    jamfAPIPass=""
    if [ "$jamfAPIEncPass" != "" ] && [ "$jamfAPIPass" == "" ]; then
	    jamfAPIPass=$(DecryptString ${jamfAPIEncPass} ${jamfAPISalt} ${jamfAPIPassPhrase})
    fi
    
    echo "Assigning to Group with ID" $staticGroupID"..."
    apiData="<computer_group><id>${staticGroupID}</id><name>${staticGroupName}</name><computer_additions><computer><name>$ComputerName</name></computer></computer_additions></computer_group>"
    curl -sS -k -i -u "${jamfAPIUser}:${jamfAPIPass}" -X PUT -H "Content-Type: text/xml" -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>$apiData" "${jamfURL}/JSSResource/computergroups/id/${staticGroupID}"
       
} 

preReqCheck(){
    if [[ "$jamfAPIEncPass" == "" ]]; then
        echo "Encrypted API Creds not found! Can not decrypt to continue; Exiting..."
        exit 0
    else
        echo "Valid encrypted API credentials found; Continuing..."
    fi

    if [[ $(jamf checkJSSConnection | grep available) == "The JSS is available." ]]; then
        echo "JSS is reachable; Continuing..."
    else  
        echo "JSS Could not be reached! Exiting..."
        exit 0
    fi
}


preReqCheck
assignDevice
