#!/bin/bash
##############################
# 10/14/16 - This will disable
# the auto check for updates
# in Sketch.
#
##############################

#get logged in user
loggedInUser=$(defaults read /Library/Preferences/com.apple.loginwindow.plist lastUserName)

#stopping sketch update
sudo defaults write  /Users/$loggedInUser/Library/Preferences/com.bohemiancoding.sketch3.plist SUEnableAutomaticChecks -bool no
sudo mv /Applications/Sketch.app/Contents/Frameworks/Sparkle.framework/Versions/A/Resources/pt_BR.lproj/SUAutomaticUpdateAlert.nib /Applications/Sketch.app/Contents/Frameworks/Sparkle.framework/Versions/A/Resources/pt_BR.lproj/SUAutomaticUpdateAlert.backup.nib
sudo mv /Applications/Sketch.app/Contents/Frameworks/Sparkle.framework/Versions/A/Resources/pt_BR.lproj/SUUpdateAlert.nib /Applications/Sketch.app/Contents/Frameworks/Sparkle.framework/Versions/A/Resources/pt_BR.lproj/SUUpdateAlert.backup.nib



#re-assign permissions
sudo chmod 744 /Users/$loggedInUser/Library/Preferences/com.bohemiancoding.sketch3.plist
