#!/bin/bash
###################################################
# KL 9/16/19                                      #
# --                                              #
# PRE-REQ: watch installed (brew install watch)   #
#   -used to watch airport file to help           #
#      when troubleshooting WiFi issues           #
###################################################

watch -n1 /System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -I en0
