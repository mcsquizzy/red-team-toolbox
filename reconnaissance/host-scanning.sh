#!/bin/bash
# Gather Host Information

####################
# Global variables #
####################

DEPENDENCIES="nmap whatweb smbmap"
SMBPORTS="445 139"
NMAPSMBSCRIPTS="smb-enum-domains.nse,smb-enum-groups.nse,smb-enum-processes.nse,smb-enum-services.nse,smb-enum-sessions.nse,smb-enum-shares.nse,smb-enum-users.nse"
#SMTPPORTS="25 465 587"


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
  echo "Enumerate Samba Shares of $IP and Port $1 ..."
  echo
  smbmap -H $IP -P $1 | tee -a software-stats.txt
}

function fuNmapSMBScan {
  echo
  echo "Nmap SMB Scan of $IP and Port $1 ..."
  echo
  nmap -Pn -oN software-stats.txt --append-output --script $NMAPSMBSCRIPTS $IP $1
}

################################
# Installation of Dependencies #
################################

fuGET_DEPS

#####################
# Software Versions #
#####################

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
# Web Analysis #
################

# whatweb
if [ "$DOMAIN" != "" ] && grep -q -w 80 "targetPort.txt"; then
  echo
  echo "Scan website $DOMAIN and recognises web technologies ..."
  echo
  whatweb $DOMAIN -v --color=never | tee web-stats.txt

elif [ "$DOMAIN" != "" ] && grep -q -w 443 "targetPort.txt"; then
  echo
  echo "Scan website $DOMAIN and recognises web technologies ..."
  echo
  whatweb $DOMAIN -v --color=never | tee web-stats.txt
 
fi


################
# SMB Analysis #
################

# test
for i in $SMBPORTS;
  do
    if grep -q -w $i "targetPort.txt"; then
      echo $i
    fi
done

# smbmap
for i in $SMBPORTS;
  do
    if grep -q -w $i "targetPort.txt"; then
      fuSambaShareEnumerate $i
    fi
done

# nmap
for i in $SMBPORTS;
  do
    if grep -q -w $i "targetPort.txt"; then
      fuNmapSMBScan $i
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
