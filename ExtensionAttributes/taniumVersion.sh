#!/usr/bin/env bash

if [[ -a /Library/Tanium/TaniumClient/TaniumClient ]]
	then
        version=$(/Library/Tanium/TaniumClient/TaniumClient -v)
        echo "<result>$version</result>"
    else
        notFound="Tanium Version not found"
	    echo "<result>$notFound</result>"
fi

