#!/usr/bin/env bash
############################### 

###############################
# Kyle LeBlanc                #
# Last Edit: 4/7/2020         #
###############################

##### Set Vars
jamfURL="https://jss.company.com"
jamfAPIUser=""
jamfAPIPass=""
#jamfAPIEncPass="" # Hardcode here for Testing Purposes
jamfAPIEncPass=$(echo ${4}) #Called from Jamf
jamfAPISalt=""
jamfAPIPassPhrase=""
jamfBindPolicyID=""
correctDomainName="" #Enter correct domain name here to do checks against
serviceAccountName="" #Service account used to do user lookup in AD
compName=$(hostname)
serialNumber=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}')
userName=$(/usr/bin/stat -f%Su /dev/console)
#####

DecryptString() {
		# Usage: ~$ DecryptString "Encrypted String" "Salt" "Passphrase"
		echo "${1}" | /usr/bin/openssl enc -aes256 -d -a -A -S "${2}" -k "${3}"  
}

getRealTimeIPFromJamf(){
    if [ "$jamfAPIEncPass" != "" ] && [ "$jamfAPIPass" == "" ]; then
	    jamfAPIPass=$(DecryptString ${jamfAPIEncPass} ${jamfAPISalt} ${jamfAPIPassPhrase})
    fi
    ipAddr=$(curl -sS -k -u "${jamfAPIUser}:${jamfAPIPass}" -X GET -H "Content-Type: text/xml" "${jamfURL}/JSSResource/computers/serialnumber/${serialNumber}" | xmllint --xpath "//computer/general/ip_address/text()" -)
    echo "========== Current LM IP Address is:" $ipAddr
}

rebind(){
    counter=0
    while [ $counter -lt 6 ]
    do
        echo "Binding to AD..."
        jamf policy -id $jamfBindPolicyID
        local domain=$( dsconfigad -show | awk '/Active Directory Domain/{print $NF}' )

        if [[ "$domain" == "$correctDomainName" ]]; then
            id -u $serviceAccountName
            # If the check was successful...
            if [[ $? == 0 ]]; then
                echo "========== Bound Succesfully!..."
                sudo jamf recon
                break
             else
                # If the check failed
                echo "========== Bound but cannot communicate with AD. Trying Again. "
                ((counter++))
            fi
        elif [[ "$domain" != "$correctDomainName" ]]; then
            ((counter++))
            echo "========== Binding failed. Trying again... Attempt ("$counter "of 5)"
        elif [[ $counter == "5" ]]; then
            echo "========== 5 of 5 Attempts made and failed. Exiting. NOT BOUND."
            exit 1
        fi
    done
}

setPassInterval() {
    echo "========== Changing passInterval to 0..."
    sudo -u $userName dsconfigad -passinterval 0
    rebind
}

unbind() {
     echo "========== Unbinding mahcine from AD..."
     dsconfigad -force -remove -u johndoe -p nopasswordhere
     local domain=$( dsconfigad -show | awk '/Active Directory Domain/{print $NF}' )
     if [[ "$domain" == "$correctDomainName" ]]; then
         echo "========== Unbinding failed..."
         exit 1
    else 
        echo "========== Unbound succesfully..."
        setPassInterval
     fi
}   

echo "========== Serial is:" $serialNumber
echo "========== CompName is:" $compName
echo "========== User is:" $userName
getRealTimeIPFromJamf
echo "---------------------------"
unbind

