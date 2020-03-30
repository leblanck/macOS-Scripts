#!/usr/bin/env bash
############################### 
#  Used to add device to rolling update groups (similar to SCCM)
#   API Encrypted password should be set in Jamf #4
#   See Confluence for more info: https://forge.lmig.com/wiki/display/EUTME/Rolling+Update+Groups
###############################
# Kyle LeBlanc                #
# Last Edit: 3/26/2020        #
###############################

## Set Vars
orgName="ASDF Inc"
jamfURL="https://jss.asdf.com"
jamfAPIUser=""
jamfAPIPass=""
#jamfAPIEncPass="" # Hardcode here for Testing Purposes
jamfAPIEncPass=$(echo ${4}) #Called from Jamf
jamfAPISalt=""
jamfAPIPassPhrase=""
ComputerName=$(hostname)

#Group A,B,C,D
declare -a groupIDs=("282" "283" "284" "285")

DecryptString() {
		# Usage: ~$ DecryptString "Encrypted String" "Salt" "Passphrase"
		echo "${1}" | /usr/bin/openssl enc -aes256 -d -a -A -S "${2}" -k "${3}"  
}
getTotalDeviceCount() {
    if [ "$jamfAPIEncPass" != "" ] && [ "$jamfAPIPass" == "" ]; then
	    jamfAPIPass=$(DecryptString ${jamfAPIEncPass} ${jamfAPISalt} ${jamfAPIPassPhrase})
    fi
    count=$(curl -sS -k -u "${jamfAPIUser}:${jamfAPIPass}" -X GET -H "Content-Type: text/xml" "${jamfURL}/JSSResource/advancedcomputersearches/id/15" | xmllint --xpath "//advanced_computer_search/computers/size/text()" -)
    echo "$count"
}

getUpdateGroupCounts(){
    if [ "$jamfAPIEncPass" != "" ] && [ "$jamfAPIPass" == "" ]; then
	    jamfAPIPass=$(DecryptString ${jamfAPIEncPass} ${jamfAPISalt} ${jamfAPIPassPhrase})
    fi
    groupCount=$(curl -sS -k -u "${jamfAPIUser}:${jamfAPIPass}" -X GET -H "Content-Type: text/xml" "${jamfURL}/JSSResource/computergroups/id/${1}" | xmllint --xpath "//computer_group/computers/size/text()" -)
    echo "$groupCount"
}

getGroupTotals(){
    managedDevicesTotal="$(getTotalDeviceCount)"
    echo "Total Device Count:" $managedDevicesTotal
    for i in ${!groupIDs[@]};
    do
        # echo "We are on array index:" ${groupIDs[$i]} //Uncomment for Testing
        if [[ ${groupIDs[$i]} == "282" ]]; then
            groupAtotal="$(getUpdateGroupCounts ${groupIDs[$i]})"
            echo "Group A total =" $groupAtotal
        elif [[ ${groupIDs[$i]} == "283" ]]; then
            groupBtotal="$(getUpdateGroupCounts ${groupIDs[$i]})"
            echo "Group B total =" $groupBtotal
        elif [[ ${groupIDs[$i]} == "284" ]]; then
            groupCtotal="$(getUpdateGroupCounts ${groupIDs[$i]})"
            echo "Group C total =" $groupCtotal
        elif [[ ${groupIDs[$i]} == "285" ]]; then
            groupDtotal="$(getUpdateGroupCounts ${groupIDs[$i]})"
            echo "Group D total =" $groupDtotal
        else
            echo "Group ID not found. Please check groupIDs array for accuracy."
        fi
    done
}

calculateGroupMaxCount() {
    #Calculate what each group Mac should be pased on group percentages (10, 15, 25, 50%) If group size needs to be updated it should be done here. (Change to Variables in the future)
    groupAMax=$(( $managedDevicesTotal*10/100 ))
    groupBMax=$(( $managedDevicesTotal*15/100 ))
    groupCMax=$(( $managedDevicesTotal*25/100 ))
    groupDMax=$(( $managedDevicesTotal*50/100 ))
    echo "Group A Max:" $groupAMax, "Spaces Available:" $(( $groupAMax - $groupAtotal ))
    echo "Group B Max:" $groupBMax, "Spaces Available:" $(( $groupBMax - $groupBtotal ))
    echo "Group C Max:" $groupCMax, "Spaces Available:" $(( $groupCMax - $groupCtotal ))
    echo "Group D Max:" $groupDMax, "Spaces Available:" $(( $groupDMax - $groupDtotal ))
}

assignDevice() {
    jamfAPIPass=""
    if [ "$jamfAPIEncPass" != "" ] && [ "$jamfAPIPass" == "" ]; then
	    jamfAPIPass=$(DecryptString ${jamfAPIEncPass} ${jamfAPISalt} ${jamfAPIPassPhrase})
    fi
    
    counter=0
    assigned=false
    while ! $assigned; do
        #Get random number from 1-20
        randomInt=$(( $RANDOM % 20 + 1 ))

        #Increment counter by 1 for each loop, until triggering last elif to break loop.
        ((counter++))

        if [ "$randomInt" -le "5" ] && [ "$groupAtotal" -lt "$groupAMax" ]; then
            echo "Assigning to Group A..."
            apiData="<computer_group><id>${groupIDs[0]}</id><name>Rolling Update Group: A</name><computer_additions><computer><name>$ComputerName</name></computer></computer_additions></computer_group>"
            curl -sS -k -i -u "${jamfAPIUser}:${jamfAPIPass}" -X PUT -H "Content-Type: text/xml" -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>$apiData" "${jamfURL}/JSSResource/computergroups/id/${groupIDs[0]}"
            assigned=true
        elif [ "$randomInt" -gt "5" ] &&  [ "$randomInt" -le "10" ] && [ "$groupBtotal" -lt "$groupBMax" ]; then
            echo "Assigning to Group B..."
            apiData="<computer_group><id>${groupIDs[1]}</id><name>Rolling Update Group: B</name><computer_additions><computer><name>$ComputerName</name></computer></computer_additions></computer_group>"
            curl -sS -k -i -u "${jamfAPIUser}:${jamfAPIPass}" -X PUT -H "Content-Type: text/xml" -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>$apiData" "${jamfURL}/JSSResource/computergroups/id/${groupIDs[1]}"
            assigned=true
        elif [ "$randomInt" -gt "10" ] &&  [ "$randomInt" -le "15" ] && [ "$groupCtotal" -lt "$groupCMax" ]; then
            echo "Assigning to Group C..."
            apiData="<computer_group><id>${groupIDs[2]}</id><name>Rolling Update Group: C</name><computer_additions><computer><name>$ComputerName</name></computer></computer_additions></computer_group>"
            curl -sS -k -i -u "${jamfAPIUser}:${jamfAPIPass}" -X PUT -H "Content-Type: text/xml" -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>$apiData" "${jamfURL}/JSSResource/computergroups/id/${groupIDs[2]}"
            assigned=true
        elif [ "$randomInt" -gt "15" ] &&  [ "$randomInt" -le "20" ] && [ "$groupDtotal" -lt "$groupDMax" ]; then
            echo "Assigning to Group D..."
            apiData="<computer_group><id>${groupIDs[3]}</id><name>Rolling Update Group: D</name><computer_additions><computer><name>$ComputerName</name></computer></computer_additions></computer_group>"
            curl -sS -k -i -u "${jamfAPIUser}:${jamfAPIPass}" -X PUT -H "Content-Type: text/xml" -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>$apiData" "${jamfURL}/JSSResource/computergroups/id/${groupIDs[3]}"
            assigned=true
        elif [ $counter == "10" ]; then
            echo "Made" $counter "attempts; Assignment not valid; Assigning to Failover Group E..."
            apiData="<computer_group><id>286</id><name>Rolling Update Group: E - Failover</name><computer_additions><computer><name>$ComputerName</name></computer></computer_additions></computer_group>"
            curl -sS -k -i -u "${jamfAPIUser}:${jamfAPIPass}" -X PUT -H "Content-Type: text/xml" -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>$apiData" "${jamfURL}/JSSResource/computergroups/id/286"
            assigned=true
        fi
    done
} 

preReqCheck(){
    if [[ $(which xmllint) == "" ]]; then
        echo "NO XML Parser Found! Exiting..."
        exit 0
    else
       echo "XML Parser found; Continuing..."
    fi

    if [[ "$jamfAPIEncPass" == "" ]]; then
        echo "Encrypted API Creds not found! Can not decrypt to continue; Exiting..."
        exit 0
    else
        echo "Valid encrypted API credentials found; Continuing...`"
    fi

    if [[ $(jamf checkJSSConnection | grep available) == "The JSS is available." ]]; then
        echo "JSS is reachable; Continuing..."
    else  
        echo "JSS Could not be reached! Exiting..."
        exit 0
    fi
}

preReqCheck
getGroupTotals
calculateGroupMaxCount
assignDevice
