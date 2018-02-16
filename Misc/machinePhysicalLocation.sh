#!/bin/sh
##########################
# LAST EDIT: KL 4/14/17  #
# USE: Obtains machines  #
# physical LAT and LONG  #
# Coordinates.           #
##########################


#Check if WiFi is turned on. If NOT turned on, then turn it on.
INTERFACE=$(networksetup -listallhardwareports | grep -A1 Wi-Fi | tail -1 | awk '{print $2}')
STATUS=$(networksetup -getairportpower $INTERFACE | awk '{print $4}')
if [ $STATUS = "Off" ] ; then
    sleep 5
    networksetup -setairportpower $INTERFACE on
fi

/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -s | tail -n +2 | awk '{print substr($0, 34, 17)"$"substr($0, 52, 4)"$"substr($0, 1, 32)}' | sort -t $ -k2,2rn | head -12 > /tmp/gl_ssids.txt

if [ $STATUS = "Off" ] ; then
    networksetup -setairportpower $INTERFACE off
fi

OLD_IFS=$IFS
IFS="$"
URL="https://maps.googleapis.com/maps/api/browserlocation/json?browser=firefox&sensor=false"
exec 5</tmp/gl_ssids.txt
while read -u 5 MAC SS SSID
do
    SSID=`echo $SSID | sed "s/^ *//g" | sed "s/ *$//g" | sed "s/ /%20/g"`
    MAC=`echo $MAC | sed "s/^ *//g" | sed "s/ *$//g"`
    SS=`echo $SS | sed "s/^ *//g" | sed "s/ *$//g"`
    URL+="&wifi=mac:$MAC&ssid:$SSID&ss:$SS"
done
IFS=$OLD_IFS

#echo $URL
curl -s -A "Mozilla" "$URL" > /tmp/gl_coordinates.txt
LAT=`cat /tmp/gl_coordinates.txt | grep \"lat\" | awk '{print $3}' | tr -d ","`
LONG=`cat /tmp/gl_coordinates.txt | grep \"lng\" | awk '{print $3}' | tr -d ","`
ACC=`cat /tmp/gl_coordinates.txt | grep \"accuracy\" | awk '{print $3}' | tr -d ","`
#echo "LAT:  $LAT"
#echo "LONG: $LONG"
#echo "ACC: $ACC"

curl -s -A "Mozilla" "http://maps.googleapis.com/maps/api/geocode/json?latlng=$LAT,$LONG&sensor=false" > /tmp/gl_address.txt
ADDRESS=`cat /tmp/gl_address.txt | grep "formatted_address" | head -1 | awk '{$1=$2=""; print $0}' | sed "s/,$//g" | tr -d \" | sed "s/^ *//g"`

#if [ "$EA" -ne 0 ] ; then
#    echo "<result>$ADDRESS (lat=$LAT, long=$LONG, acc=$ACC)</result>"
#else
    echo "$ADDRESS (lat=$LAT, long=$LONG, acc=$ACC)"
#fi

#rm /tmp/gl_ssids.txt /tmp/gl_coordinates.txt /tmp/gl_address.txt
