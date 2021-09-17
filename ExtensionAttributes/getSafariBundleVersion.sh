#!/usr/bin/env bash

Version=$(defaults read /Applications/Safari.app/Contents/Info.plist | grep CFBundleVersion | awk -F '"' '{print $2}')
/bin/echo "<result>$Version</result>"

