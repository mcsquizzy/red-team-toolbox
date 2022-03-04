#!/bin/bash
# Gather Host Information

####################
# Global variables #
####################

DEPENDENCIES="nmap"

#############
# Functions #
#############

function fuNmapSoftwareScanIP {
  echo
  echo "SYN scan with OS detection, version detection, script scanning, and traceroute of IP $1 and the top most common 1000 ports ..."
  echo
  nmap -A -oN software-stats.txt $1
}

function fuNmapSoftwareScanPort {
  echo
  echo "SYN scan with OS detection, version detection, script scanning, and traceroute of IP $1 and port $2 ..."
  echo
  nmap -A -oN software-stats.txt $1 -p$2
}

################################
# Installation of Dependencies #
################################

fuGET_DEPS

############
# Software #
############

# Host detection
# nmap 
#-A: Enable OS detection, version detection, script scanning, and traceroute

if [ "$IP" != "" ] && [ "$TCPPORT" != "" ] && [ "$UDPPORT" != "" ]; then
  fuNmapSoftwareScanPort $IP $TCPPORT,$UDPPORT

elif [ "$IP" != "" ] && [ "$TCPPORT" != "" ] && [ "$UDPPORT" == "" ]; then
  fuNmapSoftwareScanPort $IP $TCPPORT

elif [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" != "" ]; then
  fuNmapSoftwareScanPort $IP $UDPPORT

elif [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" == "" ]; then
  fuNmapSoftwareScanIP $IP

elif [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  fuNmapSoftwareScanPort $IP $PORTRANGE

fi