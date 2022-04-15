#!/bin/bash
# Gather Host Information

####################
# Global variables #
####################

DEPENDENCIES="nmap gobuster smbmap"
mySOFTWAREFILE="output/software-findings.txt"
myDIRFILE="output/directory-findings.txt"
SMBPORTS="445 139"
WORDLIST="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"
NMAPSMBSCRIPTS="smb-enum-shares"
#SMTPPORTS="25 465 587"


#############
# Functions #
#############

function fuNmapSoftwareScan {
  fuTITLE "SYN scan with OS and version detection of $1 and $2..."
  nmap -A -Pn -oN $mySOFTWAREFILE $SPOOFINGPARAMETERS $*
}

function fuSambaShareEnumerate {
  fuTITLE "Enumerate Samba Shares of $1 and port $2 ..."
  smbmap -H $1 -P $2 -q | tee -a $mySOFTWAREFILE
}

function fuNmapSMBScan {
  fuTITLE "Nmap SMB Scan of $1 and $2 ..."
  nmap -Pn -T4 -oN $mySOFTWAREFILE --append-output --script $NMAPSMBSCRIPTS $SPOOFINGPARAMETERS $*
}

################################
# Installation of Dependencies #
################################

fuGET_DEPS

###########################
# Create output directory #
###########################

if [ ! -d "output/" ]; then
  fuINFO "creating \"output/\" directory"
  mkdir output && echo "[ OK ]"
fi

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


#########################
# Directory Enumeration #
#########################

# Gobuster
if [ "$DOMAIN" != "" ] && ([ "$TCPPORT" == "443" ] || grep -q -w 443 "targetPort.txt"); then
  fuTITLE "Directory/file enumeration on website $DOMAIN ..."
  gobuster dir -u https://$DOMAIN -q -w $WORDLIST | tee -a $myDIRFILE

elif [ "$DOMAIN" != "" ] && ([ "$TCPPORT" == "80" ] || grep -q -w 80 "targetPort.txt"); then
  fuTITLE "Directory/file enumeration on website $DOMAIN ..."
  gobuster dir -u http://$DOMAIN -q -w $WORDLIST | tee -a $myDIRFILE

fi

# nmap
if [ "$IP" != "" ] && ([ "$TCPPORT" == "443" ] || grep -q -w 443 "targetPort.txt"); then
  fuTITLE "Directory/file enumeration on webserver $IP ..."
  nmap $IP -p443 --script http-enum -oN $myDIRFILE --append-output
  
elif [ "$IP" != "" ] && ([ "$TCPPORT" == "80" ] || grep -q -w 80 "targetPort.txt"); then
  fuTITLE "Directory/file enumeration on webserver $IP ..."
  nmap $IP -p80 --script http-enum -oN $myDIRFILE --append-output

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
#      fuNmapSMBScan $IP -p$i
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


#####################
# Summarize results #
#####################

fuTITLE "Findings in following files:"
if [ -s "$mySOFTWAREFILE" ]; then
  fuRESULT "Software and Version information: $mySOFTWAREFILE"
fi
if [ -s "$myDIRFILE" ]; then
  fuRESULT "Web Directory information: $myDIRFILE"
fi
if [ ! -s "$mySOFTWAREFILE" ] && [ ! -s "$myDIRFILE" ]; then 
  fuERROR "No host information found."
fi
