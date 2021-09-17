#!/bin/bash

falconVer=$( sysctl cs | grep version | awk '{print $2}' )
falconCheck=$( sysctl cs | grep customerid | awk '{print $2}' )
check="" #enter correct customerID here
notInstalled="NotInstalled"

if [[ $falconCheck == $check ]]; then
  echo "<result>$falconVer</result>"
else
  echo "<result>$notInstalled</result>"
fi
