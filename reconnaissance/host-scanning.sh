#!/bin/bash
# Gather Host Information

####################
# Global variables #
####################

DEPENDENCIES="nmap whatweb wpscan gobuster smbmap"
SMBPORTS="445 139"
NMAPSMBSCRIPTS="smb-enum-domains.nse,smb-enum-groups.nse,smb-enum-processes.nse,smb-enum-services.nse,smb-enum-sessions.nse,smb-enum-shares.nse,smb-enum-users.nse"
#SMTPPORTS="25 465 587"


#############
# Functions #
#############

function fuNmapSoftwareScan {
  fuMESSAGE "SYN scan with OS and version detection of $1 and port $2 $3 ..."
  nmap -A -Pn -oN software-stats.txt $1 -p$2,$3
}

function fuSambaShareEnumerate {
  fuMESSAGE "Enumerate Samba Shares of $1 and port $2 ..."
  smbmap -q -H $1 -P $2 | tee -a software-stats.txt
}

function fuNmapSMBScan {
  fuMESSAGE "Nmap SMB Scan of $1 and port $2 ..."
  nmap -Pn -T4 -oN software-stats.txt --append-output --script $NMAPSMBSCRIPTS $1 -p$2
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
  fuNmapSoftwareScan $IP $TCPPORT $UDPPORT

elif [ "$IP" != "" ] && [ "$TCPPORT" != "" ] && [ "$UDPPORT" == "" ]; then
  fuNmapSoftwareScan $IP $TCPPORT

elif [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" != "" ]; then
  fuNmapSoftwareScan $IP $UDPPORT

elif [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" == "" ]; then
  fuNmapSoftwareScan $IP

elif [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  fuNmapSoftwareScan $IP $PORTRANGE

fi

################
# Web Analysis #
################

# whatweb
if [ "$DOMAIN" != "" ] && (grep -q -w 80 "targetPort.txt" || grep -q -w 443 "targetPort.txt"); then
  fuMESSAGE "Scan $DOMAIN and recognise web technologies ..."
  whatweb $DOMAIN -v --color=never | tee web-stats.txt
fi

# wpscan
if [ "$DOMAIN" != "" ] && grep -q WordPress "web-stats.txt"; then
  fuMESSAGE "WordPress Security Scan of $DOMAIN ..."
  wpscan --url $DOMAIN | tee -a web-stats.txt
fi


#########################
# Directory Enumeration #
#########################

# Gobuster
if [ "$DOMAIN" != "" ] && ([ "$TCPPORT" == "443" ] || grep -q -w 443 "targetPort.txt"); then
  fuMESSAGE "Directory/file enumeration on website $DOMAIN ..."
  gobuster dir -u https://$DOMAIN -q -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt | tee -a web-stats.txt

elif [ "$DOMAIN" != "" ] && ([ "$TCPPORT" == "80" ] || grep -q -w 80 "targetPort.txt"); then
  fuMESSAGE "Directory/file enumeration on website $DOMAIN ..."
  gobuster dir -u http://$DOMAIN -q -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt | tee -a web-stats.txt

fi



################
# SMB Analysis #
################

# test
for i in $SMBPORTS;
  do
    if grep -q -w $i "targetPort.txt"; then
      echo
      echo "$i"
      echo
    fi
done

# smbmap
for i in $SMBPORTS;
  do
    if [ "$IP" != "" ] && ( grep -q -w $i "targetPort.txt" || [ "$TCPPORT" == "$i" ] ); then
      fuSambaShareEnumerate $IP $i
    fi
done

# nmap
for i in $SMBPORTS;
  do
    if [ "$IP" != "" ] && ( grep -q -w $i "targetPort.txt" || [ "$TCPPORT" == "$i" ] ); then
      fuNmapSMBScan $IP $i
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
