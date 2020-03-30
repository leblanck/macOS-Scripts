#!/bin/bash

domain=$( dsconfigad -show | awk '/Active Directory Domain/{print $NF}' )
# If the domain is correct
if [[ "$domain" == "@@@@@@@ ENTER_DOMAIN_HERE @@@@@@@@" ]]; then
     # Check the id of a user
    id -u domainAccountName #Swap for an actual account on AD (Service Account works well)
    # If the check was successful...
    if [[ $? == 0 ]]; then
       echo "<result>Bound Correctly</result>"
    else
        # If the check failed
        echo "<result>Cannot communicate with AD</result>"
    fi
else
    # If the domain returned did not match our expectations
    echo "<result>Incorrect bind</result>"
fi
exit 0
