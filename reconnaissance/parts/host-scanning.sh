#!/bin/bash
# Gather Host Information

####################
# Global variables #
####################

DEPENDENCIES="nmap gobuster smbmap"

mySOFTWAREFILE="output/software-findings.txt"
myDIRFILE="output/directory-findings.txt"
myMYSQLFILE="output/mysql-findings.txt"
mySMBFILE="output/smb-findings.txt"
mySNMPFILE="output/snmp-findings.txt"
mySMTPFILE="output/smtp-findings.txt"
mySSHFILE="output/ssh-findings.txt"
mySSLFILE="output/ssl-findings.txt"
myVNCFILE="output/vnc-findings.txt"

SMBPORTS="445 139"
SNMPPORTS="161 162"
SMTPPORTS="25 465 587"
VNCPORTS="5800 5801 5900 5901"

WORDLIST="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"

NMAPSMBSCRIPTS="smb-enum-shares"
NMAPSMTPSCRIPTS="smtp-commands,smtp-enum-users"
NMAPMYSQLSCRIPTS="mysql-databases,mysql-dump-hashes,mysql-empty-password,mysql-enum,mysql-info,mysql-query,mysql-users,mysql-vuln-cve2012-2122"
NMAPSSHSCRIPTS="ssh-hostkey,ssh-auth-methods"#,ssh2-enum-algos"
NMAPVNCSCRIPTS="vnc-info,realvnc-auth-bypass,vnc-title"

#############
# Functions #
#############

function fuNmapSoftwareScan {
  fuTITLE "SYN scan with OS and version detection of $1 and $2 ..."
  nmap -A -Pn -oN $mySOFTWAREFILE $SPOOFINGPARAMETERS $*
}

function fuGobusterScan {
  fuTITLE "Directory/file enumeration on website $1 ..."
  gobuster dir -u $1 -q -w $WORDLIST | tee -a $myDIRFILE
}

function fuNmapHttpEnumScan {
  fuTITLE "Directory/file enumeration on webserver $1 $2 ..."
  nmap --script http-enum -oN $myDIRFILE --append-output $SPOOFINGPARAMETERS $*
}

function fuNmapMYSQLScan {
  fuTITLE "Nmap MySQL Scan of $1 and $2 ..."
  nmap -sV --script $NMAPMYSQLSCRIPTS -oN $myMYSQLFILE $SPOOFINGPARAMETERS $*
}

################################
# Installation of Dependencies #
################################

#fuGET_DEPS

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
if [ "$IP" != "" ] && ([ "$TCPPORT" == "443" ] || grep -q -w 443 "targetPort.txt"); then
  fuGobusterScan https://$IP
elif [ "$DOMAIN" != "" ] && ([ "$TCPPORT" == "443" ] || grep -q -w 443 "targetPort.txt"); then
  fuGobusterScan https://$DOMAIN
fi

if [ "$IP" != "" ] && ([ "$TCPPORT" == "80" ] || grep -q -w 80 "targetPort.txt"); then
  fuGobusterScan $IP
elif [ "$DOMAIN" != "" ] && ([ "$TCPPORT" == "80" ] || grep -q -w 80 "targetPort.txt"); then
  fuGobusterScan http://$DOMAIN
fi

# nmap
if [ "$IP" != "" ] && ([ "$TCPPORT" == "443" ] || grep -q -w 443 "targetPort.txt"); then
  fuNmapHttpEnumScan $IP -p443

elif [ "$DOMAIN" != "" ] && ([ "$TCPPORT" == "443" ] || grep -q -w 443 "targetPort.txt"); then
  fuNmapHttpEnumScan $DOMAIN -p443
fi

if [ "$IP" != "" ] && ([ "$TCPPORT" == "80" ] || grep -q -w 80 "targetPort.txt"); then
  fuNmapHttpEnumScan $IP -p80

elif [ "$DOMAIN" != "" ] && ([ "$TCPPORT" == "80" ] || grep -q -w 80 "targetPort.txt"); then
  fuNmapHttpEnumScan $DOMAIN -p443
fi


##################
# MySQL Analysis #
##################

if [ "$IP" != "" ] && ([ "$TCPPORT" == "3306" ] || grep -q -w 3306 "targetPort.txt"); then
  fuNmapMYSQLScan $IP -p3306

elif [ "$DOMAIN" != "" ] && ([ "$TCPPORT" == "3306" ] || grep -q -w 3306 "targetPort.txt"); then
  fuNmapMYSQLScan $DOMAIN -p3306
fi

################
# SMB Analysis #
################

# smbmap
# nmap
for i in $SMBPORTS; do
  if [ "$IP" != "" ] && ( grep -q -w $i "targetPort.txt" || [ "$TCPPORT" == "$i" ] ); then
    fuTITLE "Enumerate Samba Shares of $IP and port $i ..."
    smbmap -H $IP -P $i -q | tee $mySMBFILE
    #fuTITLE "Nmap SMB Scan of $IP and port $i ..."
    #nmap -sV --script $NMAPSMBSCRIPTS -oN $mySMBFILE --append-output $SPOOFINGPARAMETERS $*
  fi
done

#################
# SMTP Analysis #
#################

for i in $SMTPPORTS; do
  if [ "$IP" != "" ] && ( [ "$TCPPORT" == "$i" ] || grep -q -w $i "targetPort.txt" ); then
    fuTITLE "Nmap SMTP Scan of $IP and port $i ..."
    nmap -sV --script $NMAPSMTPSCRIPTS $IP -p$i $SPOOFINGPARAMETERS -oN $mySMTPFILE
  fi
done

#################
# SNMP Analysis #
#################

# nmap
for i in $SNMPPORTS; do
  if [ "$IP" != "" ] && ( [ "$TCPPORT" == "$i" ] || [ "$UDPPORT" == "$i" ] || grep -q -w $i "targetPort.txt" ); then
    fuTITLE "Nmap SNMP Scan of $IP and port $i ..."
    nmap -sV --script snmp-info $IP -p$i $SPOOFINGPARAMETERS -oN $mySNMPFILE
    #snmp-check

  elif [ "$DOMAIN" != "" ] && ( [ "$TCPPORT" == "$i" ] || [ "$UDPPORT" == "$i" ] || grep -q -w $i "targetPort.txt" ); then
    fuTITLE "Nmap SNMP Scan of $DOMAIN and port $i ..."
    nmap -sV --script snmp-info $DOMAIN -p$i $SPOOFINGPARAMETERS -oN $mySNMPFILE
    # snmp-check
  fi
done

################
# SSH Analysis #
################

# nmap
if [ "$IP" != "" ] && ( [ "$TCPPORT" == "22" ] || grep -q -w 22 "targetPort.txt" ); then
  fuTITLE "Nmap SSH Scan of $IP and port 22 ..."
  nmap -sV --script $NMAPSSHSCRIPTS $IP -p22 $SPOOFINGPARAMETERS -oN $mySSHFILE
elif [ "$DOMAIN" != "" ] && ( [ "$TCPPORT" == "22" ] || grep -q -w 22 "targetPort.txt" ); then
  fuTITLE "Nmap SSH Scan of $DOMAIN and port 22 ..."
  nmap -sV --script $NMAPSSHSCRIPTS $DOMAIN -p22 $SPOOFINGPARAMETERS -oN $mySSHFILE
fi

################
# SSL Analysis #
################

#todo
# sslscan
if [ "$IP" != "" ] && ( [ "$TCPPORT" == "443" ] || grep -q -w 443 "targetPort.txt" ); then
  fuTITLE "SSL Scan (SSL/TLS Protocols, supported ciphers, certificates, etc.) of $IP ..."
  sslscan $IP --no-colour | tee $mySSLFILE
elif [ "$DOMAIN" != "" ] && ( [ "$TCPPORT" == "443" ] || grep -q -w 443 "targetPort.txt" ); then
  fuTITLE "SSL Scan (protocols, supported ciphers, certificates, etc.) of $DOMAIN ..."
  sslscan $DOMAIN --no-colour | tee $mySSLFILE
fi

################
# VNC Analysis #
################

# nmap
for i in $VNCPORTS; do
  if [ "$IP" != "" ] && ( [ "$TCPPORT" == "$i" ] || [ "$UDPPORT" == "$i" ] || grep -q -w $i "targetPort.txt" ); then
  fuTITLE "Nmap VNC Scan of $IP and port $i ..."
  nmap -sV --script $NMAPVNCSCRIPTS $IP -p$i $SPOOFINGPARAMETERS -oN $myVNCFILE
  
  elif [ "$DOMAIN" != "" ] && ( [ "$TCPPORT" == "$i" ] || [ "$UDPPORT" == "$i" ] || grep -q -w $i "targetPort.txt" ); then
  fuTITLE "Nmap VNC Scan of $DOMAIN and port $i ..."
  nmap -sV --script $NMAPVNCSCRIPTS $DOMAIN -p$i $SPOOFINGPARAMETERS -oN $myVNCFILE
  fi
done

# VNC Authentication
# metasploit
for i in $VNCPORTS; do
  if [ "$IP" != "" ] && [ "$TCPPORT" == "$i" ] || [ "$UDPPORT" == "$i" ] || grep -q -w $i "targetPort.txt" ); then
    fuTITLE "Looking for target $IP if a VNC Server is running ..."
    msfdb init
    msfconsole -x "use auxiliary/scanner/vnc/vnc_none_auth; set rhost $IP; set rport $i; run; exit" -q -o $myVNCFILE
  fi
done

#if [ "$IP" == "" ] && [ "$IPRANGE" != "" ]; then
#    fuTITLE "Looking for targets that are running a VNC Server ..."
#    msfdb init
#    msfconsole -x "use auxiliary/scanner/vnc/vnc_none_auth; set rhost $IPRANGE; run; exit" -q -o output/vuln-findings-vnc.txt
#fi

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
if [ -s "$myMYSQLFILE" ]; then
  fuRESULT "MySQL information: $myMYSQLFILE"
fi
if [ -s "$mySMBFILE" ]; then
  fuRESULT "SMB information: $mySMBFILE"
fi
if [ -s "$mySNMPFILE" ]; then
  fuRESULT "SNMP information: $mySNMPFILE"
fi
if [ -s "$mySMTPFILE" ]; then
  fuRESULT "SMTP information: $mySMTPFILE"
fi
if [ -s "$mySSHFILE" ]; then
  fuRESULT "SSH information: $mySSHFILE"
fi
if [ -s "$mySSLFILE" ]; then
  fuRESULT "SSL information: $mySSLFILE"
fi
if [ -s "$myVNCFILE" ]; then
  fuRESULT "VNC information: $myVNCFILE"
fi
if [ ! -s "$mySOFTWAREFILE" ] && [ ! -s "$myDIRFILE" ] && [ ! -s "$myMYSQLFILE" ] && [ ! -s "$mySMBFILE" ] && [ ! -s "$mySNMPFILE" ] && [ ! -s "$mySMTPFILE" ] [ ! -s "$mySSHFILE" ] [ ! -s "$mySSLFILE" ] [ ! -s "$myVNCFILE" ]; then 
  fuERROR "No host/software information found."
fi
echo