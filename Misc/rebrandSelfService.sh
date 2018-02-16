#!/bin/bash

##############################
#Rewrites Info.plist to      #
#change name of MenuBar item #
##############################
sudo defaults write /Applications/Wayfair\ On\ Demand.app/Contents/Info CFBundleName "Wayfair On Demand"
sudo chmod 744 /Applications/Wayfair\ On\ Demand.app/Contents/Info.plist
