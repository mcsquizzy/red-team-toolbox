#!/bin/bash
# Gather Host Information

####################
# Global variables #
####################

DEPENDENCIES="nmap"
SMBPORTS="445 139 137 138"


#############
# Functions #
#############

function fuNmapSoftwareScan {
  echo
  echo "SYN scan with OS detection, version detection, script scanning, and traceroute of $1, $2 ..."
  echo
  nmap -A -Pn -oN software-stats.txt $1 $2
}

function fuSambaShareEnumerate {
  echo
  echo "Enumerate Samba Shares of $IP and Port $1"
  smbmap -H $IP -P $1
}

################################
# Installation of Dependencies #
################################

fuGET_DEPS

####################
# Software Versions#
####################

# Host detection
# nmap 
# OS detection, version detection, script scanning, and traceroute

if [ "$IP" != "" ] && [ "$TCPPORT" != "" ] && [ "$UDPPORT" != "" ]; then
  fuNmapSoftwareScan $IP -p$TCPPORT,$UDPPORT

elif [ "$IP" != "" ] && [ "$TCPPORT" != "" ] && [ "$UDPPORT" == "" ]; then
  fuNmapSoftwareScan $IP -p$TCPPORT

elif [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" != "" ]; then
  fuNmapSoftwareScan $IP -p$UDPPORT

elif [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" == "" ]; then
  fuNmapSoftwareScan $IP

elif [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  fuNmapSoftwareScan $IP -p$PORTRANGE

fi


################
# SMB Analysis #
################

# smbmap
for i in $SMBPORTS;
  do
    if grep -q -w $i "targetPort.txt"; then
      fuSambaShareEnumerate $i
    fi
done



#################
# SMTP Analysis #
#################



#################
# SNMP Analysis #
#################



################
# SSL Analysis #
################
