#!/bin/bash
###################################
# Extension Attr. to return ONLY  #
# network interfaces that have    #
# search domains CORRECTLY set    #
###################################
# Kyle LeBlanc            #
# Last Edit: 5/28/20     #
###########################
searchDomains="SEARCH DOMAINS HERE"
declare -a networkInterfaces
declare -a correctInterfaces
IFS=$'\n' read -r -d '' -a networkInterfaces < <( networksetup -listallnetworkservices | tail -n +2 && printf '\0' )

for i in ${!networkInterfaces[@]};
do
    echo "========== Search Domains for" ${networkInterfaces[$i]} "are... =========="
    result=$(networksetup -getsearchdomains "${networkInterfaces[$i]}" | tr '\n' ' ')
    #echo "$result"
    if [[ "$result" == *"SEARCH DOMAINS HERE"* ]]; then
        echo "Search Domains are correctly set for" ${networkInterfaces[$i]}
        correctInterfaces+=(${networkInterfaces[$i]})
    else
        echo "Search Domains are NOT set for" ${networkInterfaces[$i]}
    fi
done

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "<result>The following interfaces are set correctly:" ${correctInterfaces[@]}"</result>"
