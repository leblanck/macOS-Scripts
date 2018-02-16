#!/usr/bin/env python

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# This script was modified from Andrina Kelly's version presented at JNUC2013 for allowing
# a user to elevate their privelages to administrator once per day for 30 minutes. After
# the 30 minutes if a user created a new admin account that account will have admin rights
# also revoked. If the user changed the organization admin account password, that will also
# be reset.
#
# Updated On: Feb 16th, 2018
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# IMPORTS
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

import os, plistlib, grp, subprocess, time, sys
from datetime import datetime

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# VARIABLES
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

workingDir = '/usr/local/jamfps/'                   # working directory for script
launchdFile = 'com.jamfps.adminremove.plist'        # launch daemon file location
plistFile = 'MakeMeAdmin.plist'                     # working plist location
statusFile = 'MakeMeAdmin.Status.plist'             # compliancy check plist location
tempAdminLog = 'tempAdmin.log'                      # script log file
orgAdmins = {'macadmin': sys.argv[4]}               # replace orgAdmin with your organizational admin / password passed via Jamf Pro Parameter #4
salt = 'cd73b8f69e940395'                           # decrypt salt
passphrase = '60c55a3ab03e5dfd1ed64a31'             # decrypt passphrase

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# FUNCTIONS
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

def DecryptString(inputString, salt, passphrase):
    '''Usage: >>> DecryptString("Encrypted String", "Salt", "Passphrase")'''
    p = subprocess.Popen(['/usr/bin/openssl', 'enc', '-aes256', '-d', '-a', '-A', '-S', salt, '-k', passphrase], stdin = subprocess.PIPE, stdout = subprocess.PIPE)
    return p.communicate(inputString)[0]

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# APPLICATION
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

if os.path.exists(workingDir + plistFile):
    # remove user admin rights
    user2Remove = plistlib.readPlist(workingDir + plistFile).User2Remove
    subprocess.call(["dseditgroup", "-o", "edit", "-d", user2Remove, "-t", "user", "admin"])
    # add log entry
    log = open(workingDir + tempAdminLog, "a+")
    log.write("{} - MakeMeAdmin Removed Admin Rights for {}\r\n".format(datetime.now(), user2Remove))
    log.close()
    print 'Revoked Admin Rights for ' + user2Remove
    # compre prior to current admin lists
    print 'Checking for newly created admin accounts...'
    priorAdmins = plistlib.readPlist(workingDir + plistFile).CurrentAdminUsers
    currentAdmins = grp.getgrnam('admin').gr_mem
    newAdmins = set(currentAdmins).difference(set(priorAdmins))
    newAdm = ''
    if not newAdmins:
        print '   No New Accounts Found!'
        # update compliancy plist
        status = { 'Status':'Compliant'}
        plistlib.writePlist(status, workingDir + statusFile)
    else:
        print '   New Admin Accounts Found!'
        log = open(workingDir + tempAdminLog, "a+")
        log.write("{} - MakeMeAdmin Discovered New Admin Accounts: {}\r\n".format(datetime.now(), list(newAdmins)))
        log.close()
        # update status plist
        status = { 'Status':'Remediated',
                   'newAdmins':'newAdmin Created',
                   'orgAdmin':'orgAdmin OK'}
        plistlib.writePlist(status, workingDir + statusFile)
        newAdm = plistlib.readPlist(workingDir + statusFile).newAdmins
        # loop through new admin accounts and remove admin rights
        print '   Removing Admin Rights for New Admin Accounts...'
        for user in newAdmins:
            subprocess.call(["dseditgroup", "-o", "edit", "-d", user, "-t", "user", "admin"])
            log = open(workingDir + tempAdminLog, "a+")
            log.write("{} - MakeMeAdmin Removed Admin Rights for: {}\r\n".format(datetime.now(), user))
            log.close()
            print '      Removed Admin Rights for ' + user
            time.sleep(1)
    # check if organization admin(s) are valid
    print 'Checking organizational admin passwords...'
    for admin, admpass in orgAdmins.iteritems():
        # decrypt password
        admpassDecrypted = DecryptString(admpass, salt, passphrase)
        admpassDecrypted = admpassDecrypted.replace('\n', '')
        admpassDecrypted = admpassDecrypted.replace('\x05', '')
        admpassDecrypted = admpassDecrypted.strip()
        time.sleep(1)
        valid = subprocess.call(["dscl", "/Local/Default", "-authonly", admin, admpassDecrypted])
        time.sleep(1)
        if valid == 0:
            log = open(workingDir + tempAdminLog, "a+")
            log.write("{} - orgAdmin Password is Valid \r\n".format(datetime.now()))
            log.close()
            print 'Password for orgAdmin: ' + admin + ' is valid!'
        else:
            log = open(workingDir + tempAdminLog, "a+")
            log.write("{} - orgAdmin Password is Invalid! \r\n".format(datetime.now()))
            log.close()
            result = subprocess.call(["dscl", ".", "passwd", "/Users/" + admin, admpassDecrypted])
            time.sleep(3)
            print 'Password for orgAdmin: ' + admin + ' was invalid!'
            if result == 0:
                log = open(workingDir + tempAdminLog, "a+")
                log.write("{} - orgAdmin Password Successfully Reset! \r\n".format(datetime.now()))
                log.close()
                print 'Password Successfully Reset for ' + admin + "!"
                if not newAdm:
                    # update status plist
                    status = { 'Status':'Remediated',
                               'newAdmins':'No newAdmins',
                               'orgAdmin':'orgAdmin OK'}
                    plistlib.writePlist(status, workingDir + statusFile)
                else:
                    # update status plist
                    status = { 'Status':'Remediated',
                               'newAdmins':'newAdmin Created',
                               'orgAdmin':'orgAdmin OK'}
                    plistlib.writePlist(status, workingDir + statusFile)
            else:
                log = open(workingDir + tempAdminLog, "a+")
                log.write("{} - Error Resetting orgAdmin Password! \r\n".format(datetime.now()))
                log.close()
                print 'Error Resetting Password for ' + admin + "!"
                if not newAdm:
                    # update status plist
                    status = { 'Status':'Violation',
                               'newAdmins':'No newAdmins',
                               'orgAdmin':'orgAdmin ERROR'}
                    plistlib.writePlist(status, workingDir + statusFile)
                else:
                    # update status plist
                    status = { 'Status':'Violation',
                               'newAdmins':'newAdmin Created',
                               'orgAdmin':'orgAdmin ERROR'}
                    plistlib.writePlist(status, workingDir + statusFile)
    os.remove(workingDir + plistFile)

if os.path.exists('/Library/LaunchDaemons/' + launchdFile):
    print 'Removing LaunchDaemon...'
    os.remove('/Library/LaunchDaemons/' + launchdFile)

# Submit Jamf Pro Inventory
subprocess.call(["/usr/local/jamf/bin/jamf", "recon"])
