#!/bin/bash
# Gather Host Information

####################
# Global variables #
####################

DEPENDENCIES="nmap whatweb wpscan gobuster smbmap"
mySOFTWAREFILE="software-findings.txt"
myWEBFILE="web-findings.txt"
SMBPORTS="445 139"
WORDLIST="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"
NMAPSMBSCRIPTS="smb-enum-shares.nse"
#SMTPPORTS="25 465 587"


#############
# Functions #
#############

function fuNmapSoftwareScan {
  fuMESSAGE "SYN scan with OS and version detection of $1 ..."
  nmap -A -Pn -oN $mySOFTWAREFILE $1 $2
}

function fuSambaShareEnumerate {
  fuMESSAGE "Enumerate Samba Shares of $1 and port $2 ..."
  smbmap -H $1 -P $2 | tee -a $mySOFTWAREFILE
}

function fuNmapSMBScan {
  fuMESSAGE "Nmap SMB Scan of $1 and port $2 ..."
  nmap -Pn -T4 -oN $mySOFTWAREFILE --append-output --script $NMAPSMBSCRIPTS $1 -p$2
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
if [ "$DOMAIN" != "" ] && (grep -q -w 80 "targetPort.txt" || grep -q -w 443 "targetPort.txt"); then
  fuMESSAGE "Scan $DOMAIN and recognise web technologies ..."
  whatweb $DOMAIN -v -q --no-errors --color=never | tee $myWEBFILE
fi

if [ "$IP" != "" ] && (grep -q -w 80 "targetPort.txt" || grep -q -w 443 "targetPort.txt"); then
  fuMESSAGE "Scan $IP and recognise web technologies ..."
  whatweb $IP -v -q --no-errors --color=never | tee $myWEBFILE
fi

# wpscan
if [ "$DOMAIN" != "" ] && grep -q WordPress "$myWEBFILE"; then
  fuMESSAGE "WordPress Security Scan of $DOMAIN ..."
  wpscan --url $DOMAIN | tee -a $myWEBFILE
fi


#########################
# Directory Enumeration #
#########################

# Gobuster
if [ "$DOMAIN" != "" ] && ([ "$TCPPORT" == "443" ] || grep -q -w 443 "targetPort.txt"); then
  fuMESSAGE "Directory/file enumeration on website $DOMAIN ..."
  gobuster dir -u https://$DOMAIN -q -w $WORDLIST | tee -a $myWEBFILE

elif [ "$DOMAIN" != "" ] && ([ "$TCPPORT" == "80" ] || grep -q -w 80 "targetPort.txt"); then
  fuMESSAGE "Directory/file enumeration on website $DOMAIN ..."
  gobuster dir -u http://$DOMAIN -q -w $WORDLIST | tee -a $myWEBFILE

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
#for i in $SMBPORTS;
#  do
#    if [ "$IP" != "" ] && ( grep -q -w $i "targetPort.txt" || [ "$TCPPORT" == "$i" ] ); then
#      fuNmapSMBScan $IP $i
#    fi
#done


#################
# SMTP Analysis #
#################


#################
# SNMP Analysis #
#################


################
# SSL Analysis #
################
