#!/bin/bash
# Gather Host Information

####################
# Global variables #
####################

DEPENDENCIES="nmap"

#############
# Functions #
#############

function fuNmapSoftwareScan {
  echo
  echo "SYN scan with OS detection, version detection, script scanning, and traceroute of $1, $2 ..."
  echo
  nmap -A -oN software-stats.txt $1 $2
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
#-A: Enable OS detection, version detection, script scanning, and traceroute

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


#################
# SMTP Analysis #
#################


#################
# SNMP Analysis #
#################



################
# SSL Analysis #
################
