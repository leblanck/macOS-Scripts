#!/bin/bash

if [[ $(command -v code) == "" ]]; then
     echo "<result>VSCode is not installed.</result>"
else
     installedList=$(code --list-extensions)
     echo "<result>$installedList</result>"
fi
