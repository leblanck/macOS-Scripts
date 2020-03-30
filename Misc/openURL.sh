#!/bin/bash
##################################
# Open a URL as current user     #
##################################
# Last Edit: 1/31/2020          #
##################################

# Get username of locally logged in user
userName=$(/usr/bin/stat -f%Su /dev/console)

# Open page in locally logged in user's default web browser
sudo -u $userName open "$4"
