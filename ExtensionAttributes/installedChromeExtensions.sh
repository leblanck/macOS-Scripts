#!/bin/bash

loggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`
JSONS=$( find "/Users/${loggedInUser}/Library/Application Support/Google/Chrome/Default/Extensions/" -maxdepth 4 -name "manifest.json" )

while read JSON; do
    NAME=$( awk -F'"' '/name/{print $4}' "$JSON" )
    if [[ ! -z "$NAME" ]] && [[ ! "$NAME" =~ "_MSG_" ]]; then
        EXTS+=( "${NAME}" 
    fi
done < <(echo "$JSONS")
​
echo "<result>$(printf '%s\n' "${EXTS[@]}")</result>"
