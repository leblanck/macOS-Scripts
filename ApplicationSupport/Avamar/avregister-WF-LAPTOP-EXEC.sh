#!/bin/sh
#
# avregister (Avamar Client Registration)
#
# Use:
#    This script should be run to establish communication with the DPN MC Server.
#    Neither avtar nor avagent will function until properly refistered with the MC server.
#
#    a. Obtain MCSADDR
#    b. Obtain DPNDOMAIN
#    c. Obtain UAL (User Access List)
#    d. Initialize avagent with new MCSADDR, DPNDOMAIN and UAL
#        (avagent.d does stop possible previous avagent and restart avagent)
#

VERSION="1"

PLISTBUDDY_CMD="/usr/libexec/PlistBuddy"
# On Mac OS X, read the BASEDIR from the com.avamar.AvamarClient,baseDir key; if that fails
# use the /usr/local/avamar directory
BASEDIR="$($PLISTBUDDY_CMD /Library/Preferences/com.avamar.AvamarClient.plist -c "Print :baseDir" 2> /dev/null || echo /usr/local/avamar)"
LAUNCHD_CFG="/Library/LaunchDaemons/com.avamar.avagent.plist"

#
# find what platform we are on
#
platform=`uname -s`

# We need root privileges to run this script
if [ `whoami` != "root" ]
then
    echo "Please run avregister as the super-user. (For example: sudo $0 "$@")."
    exit 1
fi

# Return true (0) if agent is running, false otherwise
avagent_is_running()
{
    if [ ! -e "${BASEDIR}/var/avagent.lck" ]
    then
        return 1
    fi

    AGENT_PID=`cat "${BASEDIR}/var/avagent.lck" | awk '{print $1}'`

    kill -0 ${AGENT_PID} > /dev/null 2>&1

    if [ $? -eq 0 ]
    then
        return 0
    fi

    return 1
}

avagent_stop()
{
    echo 'Stopping avagent...'
    /bin/launchctl unload ${LAUNCHD_CFG}

    while avagent_is_running
    do
        sleep 1
    done

    return 0
}

avagent_start()
{
    echo 'Starting avagent...'
    /bin/launchctl load ${LAUNCHD_CFG}

    while ! avagent_is_running
    do
        sleep 1
    done

    return 0
}

avagent_register()
{
    MCSADDR=$1
    DPNDOMAIN=$2
    MCSGROUPLIST=$3
    #shift; shift; shift; UAL=$*
    if [ ! ${MCSADDR} ] || [ ! ${DPNDOMAIN} ]; then
        echo "Activation Parameter Error!"
        echo "Syntax:  $startedas register|activate MCADDR DPNDOMAIN"
        return 1;
    fi

    # stop any running daemon
    avagent_stop
    if [ $? -ne 0 ]; then
        return 1;
    fi

    "${BASEDIR}/bin/avagent.bin" --sysdir="${BASEDIR}/etc" \
                                 --vardir="${BASEDIR}/var" \
                                 --quiet \
                                 --init  \
                                 --daemon=false \
                                 --mcsaddr=\"${MCSADDR}\" \
                                 --dpndomain=\"${DPNDOMAIN}\" \
                                 --mcsgrouplist=\"${MCSGROUPLIST}\" \

    REGRSLT=$?
    if [ $REGRSLT -eq 0 ]; then
        echo "Client activated successfully."
    else
        echo "Client activation error."
    fi

    # start daemon
    avagent_start

    return ${REGRSLT}
}

# We need an "echo" that interprets escape sequences such as "\c"
# meaning "no newline".  Solaris' /bin/echo does this by default.
# GNU/Linux /bin/echo requires the -e option to enable this mode.
# Unfortunately Solaris "/bin/echo -e" prints "-e", so we must figure
# out which to use in each case.
#
if [ "`/bin/echo '\c'`" = "" ]; then
   ECHO_ESC="/bin/echo"
else
   ECHO_ESC="/bin/echo -e"
fi

avagent_cmd_register()
{
    echo
    echo "=== Client Registration and Activation - FOR WAYFAIR"
    echo "This script will register and activate the client with the Administrator server."

    UNREGISTERED=1
    MCSADDR="bo1ave01.csnzoo.com"
    while [ ${UNREGISTERED} -ne 0 ]
    do
      DPNDOMAIN="clients/laptop"
      MCSGROUPLIST="/clients/laptop/All-Wayfair-Apple-Executive"
      echo "Admin Server address (DNS) added."
      #$ECHO_ESC "Enter the Administrator server address (DNS text name, not numeric IP address): \c"
      #read MCSADDR

      #while [ "${MCSADDR}" = "" ]
      #do
      #  $ECHO_ESC "You must enter an Administrator server address: \c"
      #  read MCSADDR
      #done

      echo "Added domain [/clients/laptop]"
      #$ECHO_ESC "Enter the Axion server domain [${DPNDOMAIN}]: \c"
      #read dpndomain
      #if [ "${dpndomain}" != "" ]; then
      #  DPNDOMAIN=${dpndomain}
      #fi

      echo "Added Group [EXEC - Apple]"
      # Register with MCS
      avagent_register ${MCSADDR} ${DPNDOMAIN} ${MCSGROUPLIST}

      UNREGISTERED=$?
    done
    echo "Registration Complete."
}

avagent_cmd_unregister()
{
    avagent_stop
    if [ $? -ne 0 ]
    then
        echo "Unable to stop avagent. Aborting."
        exit 1
    fi

    "${BASEDIR}/bin/avagent.bin" --sysdir="${BASEDIR}/etc" --vardir="${BASEDIR}/var" --daemon=false --uninit > /dev/null 2>&1
}



case "$1" in
    register)
        avagent_cmd_register
        ;;

    unregister)
        avagent_cmd_unregister
        ;;

    stop)
        avagent_stop
        ;;

    start)
        avagent_start
        ;;

    restart)
        avagent_stop
        avagent_start
        ;;
    *)
        if [ -z "$1" ]
        then
            avagent_cmd_register
        fi
esac
