#!/bin/bash
############################
#
#
#
#
#
#############################

#change to background location dir
cd /Library/Caches/

#make backup of old background
mv /Library/Caches/com.apple.desktop.admin.png /Library/Caches/com.apple.desktop.admin_BACKUP.png

#move new background
mv /Users/Shared/com.apple.desktop.admin.png /Library/Caches/
