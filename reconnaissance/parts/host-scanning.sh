#!/bin/bash
# Gather Host Information

####################
# Global variables #
####################

DEPENDENCIES="nmap gobuster smbmap"

myVERSIONFILE="output/software-infos/version-findings.txt"
myDIRFILE="output/software-infos/directory-findings.txt"
myLDAPFILE="output/software-infos/ldap-findings.txt"
myFTPFILE="output/software-infos/fdp-findings.txt"
myMYSQLFILE="output/software-infos/mysql-findings.txt"
mySMBFILE="output/software-infos/smb-findings.txt"
mySNMPFILE="output/software-infos/snmp-findings.txt"
mySMTPFILE="output/software-infos/smtp-findings.txt"
mySSHFILE="output/software-infos/ssh-findings.txt"
mySSLFILE="output/software-infos/ssl-findings.txt"
myVNCFILE="output/software-infos/vnc-findings.txt"

WEBPORTS="80 81 300 443 591 593 832 981 1010 1311 1099 2082 2095 2096 2480 3000 3128 3333 4243 4567 4711 4712 4993 5000 5104 5108 5280 5281 5800 6543 7000 7396 7474 8000 8001 8008 8014 8042 8069 8080 8081 8083 8088 8090 8091 8118 8123 8172 8222 8243 8280 8281 8333 8337 8443 8500 8834 8880 8888 8983 9000 9043 9060 9080 9090 9091 9200 9443 9800 9981 10000 11371 12443 16080 18091 18092 20720 55672"
LDAPPORTS="389 636 3268 3269"
SMBPORTS="445 139"
SNMPPORTS="161 162"
SMTPPORTS="25 465 587"
VNCPORTS="5800 5801 5900 5901"

WORDLIST="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"

NMAPSMBSCRIPTS="smb-enum-shares,smb-enum-users"
NMAPSMTPSCRIPTS="smtp-commands,smtp-enum-users"
NMAPMYSQLSCRIPTS="mysql-databases,mysql-dump-hashes,mysql-empty-password,mysql-enum,mysql-info,mysql-query,mysql-users,mysql-vuln-cve2012-2122"
NMAPSSHSCRIPTS="ssh-hostkey,ssh-auth-methods"
NMAPVNCSCRIPTS="vnc-info,realvnc-auth-bypass,vnc-title"


#############
# Functions #
#############

function fuNmapVersionScan {
  fuTITLE "Nmap scan with OS and version detection of $* ..."
  nmap -O -sV -Pn -oN $myVERSIONFILE $SPOOFINGPARAMETERS $*
}

function fuGobusterScan {
  fuTITLE "Directory/file enumeration on website $1 ..."
  gobuster dir -u $1 -q -w $WORDLIST | tee -a $myDIRFILE
}

function fuNmapHttpEnumScan {
  fuTITLE "Directory/file enumeration on webserver $1 $2 ..."
  nmap --script http-enum -oN $myDIRFILE --append-output $SPOOFINGPARAMETERS $*
}


################################
# Installation of Dependencies #
################################

if [ "$IAMROOT" ] && [ "$INET" ]; then
  fuGET_DEPS
else
  fuMESSAGE "Installation of dependencies skipped."
fi


###########################
# Create output directory #
###########################

if [ ! -d "output/software-infos" ]; then
  fuINFO "Creating \"./output/software-infos\" directory"
  mkdir -p output/software-infos && echo "[ OK ]"
  echo
fi


#####################
# Software Versions #
#####################

# Host detection
# nmap 
# OS detection, version detection, script scanning, and traceroute
if [ "$IP" != "" ] && [ "$TCPPORT" != "" ] && [ "$UDPPORT" != "" ]; then
  fuNmapVersionScan $IP -p$TCPPORT,$UDPPORT

elif [ "$IP" != "" ] && [ "$TCPPORT" != "" ] && [ "$UDPPORT" == "" ]; then
  fuNmapVersionScan $IP -p$TCPPORT

elif [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" != "" ]; then
  fuNmapVersionScan $IP -p$UDPPORT

elif [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" == "" ]; then
  fuNmapVersionScan $IP

elif [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  fuNmapVersionScan $IP -p$PORTRANGE
fi


#####################################
# Directory Enumeration (Webserver) #
#####################################

# Gobuster
if [ "$IP" != "" ] && ( [ "$TCPPORT" == "443" ] || grep -q -w "443" targetPort.txt ); then
  fuGobusterScan https://$IP
elif [ "$DOMAIN" != "" ] && ( [ "$TCPPORT" == "443" ] || grep -q -w "443" targetPort.txt ); then
  fuGobusterScan https://$DOMAIN
fi

if [ "$IP" != "" ] && ( [ "$TCPPORT" == "80" ] || grep -q -w "80" targetPort.txt ); then
  fuGobusterScan $IP
elif [ "$DOMAIN" != "" ] && ( [ "$TCPPORT" == "80" ] || grep -q -w "80" targetPort.txt ); then
  fuGobusterScan http://$DOMAIN
fi

# nmap
if [ "$IP" != "" ] && ( [ "$TCPPORT" == "443" ] || grep -q -w "443" targetPort.txt ); then
  fuNmapHttpEnumScan $IP -p443

elif [ "$DOMAIN" != "" ] && ( [ "$TCPPORT" == "443" ] || grep -q -w "443" targetPort.txt ); then
  fuNmapHttpEnumScan $DOMAIN -p443
fi

if [ "$IP" != "" ] && ( [ "$TCPPORT" == "80" ] || grep -q -w "80" targetPort.txt ); then
  fuNmapHttpEnumScan $IP -p80

elif [ "$DOMAIN" != "" ] && ( [ "$TCPPORT" == "80" ] || grep -q -w "80" targetPort.txt ); then
  fuNmapHttpEnumScan $DOMAIN -p443
fi


###################
# FDP Enumeration #
###################

# nmap
if [ "$IP" != "" ] && ( [ "$TCPPORT" == "21" ] || grep -q -w "21" targetPort.txt ); then
  fuTITLE "Nmap FTP scan of $IP and port 21 ..."
  nmap -sV --script "ftp-* and not brute" $IP -p 21 $SPOOFINGPARAMETERS -oN $myFTPFILE
fi


####################
# LDAP Enumeration #
####################

#todo
# nmap
for ldapport in $LDAPPORTS; do
  if [ "$IP" != "" ] && ( [ "$TCPPORT" == "$ldapport" ] || grep -q -w "$ldapport" targetPort.txt ); then
    fuTITLE "Nmap LDAP scan (public information) of $IP and port $ldapport ..."
    nmap -sV --script "ldap* and not brute" $IP -p$ldapport $SPOOFINGPARAMETERS -oN $myLDAPFILE
  fi
done

# LDAP user enumeration
#nmap -p 88 --script=krb5-enum-users --script-args="krb5-enum-users.realm='DOMAIN'" <IP>
#nmap --script dns-srv-enum --script-args "dns-srv-enum.domain='domain.com'"

# ldapsearch


##################
# MySQL Analysis #
##################

# nmap
if [ "$IP" != "" ] && ( [ "$TCPPORT" == "3306" ] || grep -q -w "3306" targetPort.txt ); then
  fuTITLE "Nmap MySQL scan of $IP and port 3306 ..."
  nmap -sV --script $NMAPMYSQLSCRIPTS $IP -p3306 -oN $myMYSQLFILE $SPOOFINGPARAMETERS

elif [ "$DOMAIN" != "" ] && ( [ "$TCPPORT" == "3306" ] || grep -q -w "3306" targetPort.txt ); then
  fuTITLE "Nmap MySQL scan of $DOMAIN and port 3306 ..."
  nmap -sV --script $NMAPMYSQLSCRIPTS $DOMAIN -p3306 -oN $myMYSQLFILE $SPOOFINGPARAMETERS
fi


################
# SMB Analysis #
################

# smbmap
# nmap
for smbport in $SMBPORTS; do
  if [ "$IP" != "" ] && ( [ "$TCPPORT" == "$smbport" ] || grep -q -w "$smbport" targetPort.txt ); then
    fuTITLE "Enumerate Samba Shares of $IP and port $smbport ..."
    smbmap -H $IP -P $smbport -q | tee -a $mySMBFILE
    fuTITLE "Nmap SMB scan of $IP and port $smbport ..."
    nmap -sV --script $NMAPSMBSCRIPTS $IP -p$smbport $SPOOFINGPARAMETERS -oN $mySMBFILE --append-output
  fi
done


#################
# SMTP Analysis #
#################

# nmap
for smtpport in $SMTPPORTS; do
  if [ "$IP" != "" ] && ( [ "$TCPPORT" == "$smtpport" ] || grep -q -w "$smtpport" targetPort.txt ); then
    fuTITLE "Nmap SMTP scan of $IP and port $smtpport ..."
    nmap -sV --script $NMAPSMTPSCRIPTS $IP -p$smtpport $SPOOFINGPARAMETERS -oN $mySMTPFILE
  fi
done


#################
# SNMP Analysis #
#################

# nmap
for snmpport in $SNMPPORTS; do
  if [ "$IP" != "" ] && ( [ "$TCPPORT" == "$snmpport" ] || [ "$UDPPORT" == "$snmpport" ] || grep -q -w "$snmpport" targetPort.txt ); then
    fuTITLE "Nmap SNMP scan of $IP and port $snmpport ..."
    nmap -sV --script snmp-info $IP -p$snmpport $SPOOFINGPARAMETERS -oN $mySNMPFILE
    #snmp-check

  elif [ "$DOMAIN" != "" ] && ( [ "$TCPPORT" == "$snmpport" ] || [ "$UDPPORT" == "$snmpport" ] || grep -q -w "$snmpport" targetPort.txt ); then
    fuTITLE "Nmap SNMP scan of $DOMAIN and port $snmpport ..."
    nmap -sV --script snmp-info $DOMAIN -p$snmpport $SPOOFINGPARAMETERS -oN $mySNMPFILE
    # snmp-check
  fi
done


################
# SSH Analysis #
################

# nmap
if [ "$IP" != "" ] && ( [ "$TCPPORT" == "22" ] || grep -q -w "22" targetPort.txt ); then
  fuTITLE "Nmap SSH scan of $IP and port 22 ..."
  nmap -sV --script $NMAPSSHSCRIPTS $IP -p22 $SPOOFINGPARAMETERS -oN $mySSHFILE

elif [ "$DOMAIN" != "" ] && ( [ "$TCPPORT" == "22" ] || grep -q -w "22" targetPort.txt ); then
  fuTITLE "Nmap SSH scan of $DOMAIN and port 22 ..."
  nmap -sV --script $NMAPSSHSCRIPTS $DOMAIN -p22 $SPOOFINGPARAMETERS -oN $mySSHFILE
fi


################
# SSL Analysis #
################

#todo
# sslscan
if [ "$IP" != "" ] && ( [ "$TCPPORT" == "443" ] || grep -q -w "443" targetPort.txt ); then
  fuTITLE "SSL scan (SSL/TLS protocols, supported ciphers, certificates, etc.) of $IP ..."
  sslscan $IP --no-colour | tee $mySSLFILE

elif [ "$DOMAIN" != "" ] && ( [ "$TCPPORT" == "443" ] || grep -q -w "443" targetPort.txt ); then
  fuTITLE "SSL scan (protocols, supported ciphers, certificates, etc.) of $DOMAIN ..."
  sslscan $DOMAIN --no-colour | tee $mySSLFILE
fi


################
# VNC Analysis #
################

# nmap
for vncport in $VNCPORTS; do
  if [ "$IP" != "" ] && ( [ "$TCPPORT" == "$vncport" ] || [ "$UDPPORT" == "$vncport" ] || grep -q -w "$vncport" targetPort.txt ); then
  fuTITLE "Nmap VNC scan of $IP and port $vncport ..."
  nmap -sV --script $NMAPVNCSCRIPTS $IP -p$vncport $SPOOFINGPARAMETERS -oN $myVNCFILE
  
  elif [ "$DOMAIN" != "" ] && ( [ "$TCPPORT" == "$vncport" ] || [ "$UDPPORT" == "$vncport" ] || grep -q -w "$vncport" targetPort.txt ); then
  fuTITLE "Nmap VNC scan of $DOMAIN and port $vncport ..."
  nmap -sV --script $NMAPVNCSCRIPTS $DOMAIN -p$vncport $SPOOFINGPARAMETERS -oN $myVNCFILE
  fi
done

# VNC Authentication
# metasploit
for vncport in $VNCPORTS; do
  if [ "$IP" != "" ] && ( [ "$TCPPORT" == "$vncport" ] || [ "$UDPPORT" == "$vncport" ] || grep -q -w "$vncport" targetPort.txt ); then
    fuTITLE "Looking for target $IP if a VNC Server is running ..."
    msfdb init
    msfconsole -x "use auxiliary/scanner/vnc/vnc_none_auth; set rhost $IP; set rport $vncport; run; exit" -q -o $myVNCFILE
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

if [ -s "$myVERSIONFILE" ]; then
  fuRESULT "Software and version information: $myVERSIONFILE"
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

if [ ! -s "$myVERSIONFILE" ] && [ ! -s "$myDIRFILE" ] && [ ! -s "$myLDAPFILE" ] && [ ! -s "$myMYSQLFILE" ] && [ ! -s "$mySMBFILE" ] && [ ! -s "$mySNMPFILE" ] && [ ! -s "$mySMTPFILE" ] && [ ! -s "$mySSHFILE" ] && [ ! -s "$mySSLFILE" ] && [ ! -s "$myVNCFILE" ]; then 
  fuERROR "No host/software information found."
fi
echo