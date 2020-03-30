#!/bin/bash
####################################
# Prints out list of currently     #
# installed Configuration profiles #
# on the current machine. Returns  #
# Name Attr. NOT UUID of Config.   #
#                                  #
# KL - 4/18/19                     #
####################################


profiles -C -v | grep attribute | awk '/name/{$1=$2=$3=""; print $0}' | sed 's/^ *//'
