#!/bin/bash
# Gather Network Information

####################
# Global variables #
####################

DEPENDENCIES="whois dnsenum amass python3-dnspython fping netdiscover responder nmap"

myDNSFILE="output/network-infos/dns-findings.txt"
myWHOISFILE="output/network-infos/whois-findings.txt"
myNETADDRFILE="output/network-infos/net-addr-findings.txt"
mySECAPPLFILE="output/network-infos/sec-appliance-findings.txt"
myDHCPFILE="output/network-infos/dhcp-findings.txt"
myPORTFILE="output/network-infos/port-findings.txt"
myUPORTFILE="output/network-infos/uport-findings.txt"


#############
# Functions #
#############

# NMAP Scans
function fuNmapTCPScan {
  fuTITLE "Nmap TCP SYN scan of $* ..."
  if [ "$IAMROOT" ]; then
    nmap -sS -Pn -oN $myPORTFILE $SPOOFINGPARAMETERS $*
  else
    fuERROR "You're not root. TCP SYN scan needs root privileges. Try \"sudo $0\""
  fi
}

function fuNmapTCPScanIPRANGE {
  fuTITLE "Nmap TCP SYN scan of $* ... (might take some time)"
  if [ "$IAMROOT" ]; then
    nmap -sS -T4 --min-hostgroup=64 -oN $myPORTFILE -oG ip-grepable.txt $SPOOFINGPARAMETERS $*
  else
    fuERROR "You're not root. TCP SYN scan needs root privileges. Try \"sudo $0\""
  fi
}

function fuNmapUDPScan {
  fuTITLE "Nmap UDP scan of $* ..."
  if [ "$IAMROOT" ]; then
    nmap -sU -Pn -sV --version-light -T4 -oN $myUPORTFILE $SPOOFINGPARAMETERS $* --host-timeout 120s
  else
    fuERROR "You're not root. UDP scan needs root privileges. Try \"sudo $0\""
  fi
}

function fuNmapUDPScanIPRANGE {
  fuTITLE "Nmap UDP scan of $* ... (might take some time)"
  if [ "$IAMROOT" ]; then
    nmap -sU -sV --version-light -T5 -oN $myPORTFILE --append-output -oG ip-grepable.txt $SPOOFINGPARAMETERS $* --host-timeout 120s
  else
    fuERROR "You're not root. UDP scan needs root privileges. Try \"sudo $0\""
  fi
}

# neak through certain non-stateful firewalls and packet filtering routers
function fuNmapExoticScan {
  if grep -q -w filtered $myPORTFILE; then
    fuINFO "Target might be behind a firewall, trying Exotic Scan Flags"
    if [ "$IAMROOT" ]; then
      fuNmapFINScan $*
    else
      fuERROR "You're not root. Exotic scan needs root privileges. Try \"sudo $0\""
    fi
  fi
}

# FIN scan (-sF), Sets just the TCP FIN bit.
# open|filtered = No response received, port might be open
# IDS and IPS Evasion (https://book.hacktricks.xyz/pentesting/pentesting-network/ids-evasion)
function fuNmapFINScan {
  fuTITLE "Nmap FIN scan of $* ..."
  nmap -sF -Pn -oN $myPORTFILE --append-output $SPOOFINGPARAMETERS $* --data-length 25 -f
}

# Null scan (-sN), Does not set any bits (TCP flag header is 0)
function fuNmapNULLScan {
  fuTITLE "Nmap NULL scan of $* ..."
  nmap -sN -Pn -oN $myPORTFILE --append-output $SPOOFINGPARAMETERS $* --data-length 25 -f
}


# Print scan result to usable list
function fuPrepareTargetIP {
  fuINFO "Write IP list of result to targetIP.txt ..."
  cat ip-grepable.txt | awk '/open/ {print $2}' | cat > targetIP.txt && rm ip-grepable.txt
  fuINFO "Found $(cat targetIP.txt | wc -l) IP address(es) with status \"Up\""
}

function fuPrepareTargetIPAppend {
  fuINFO "Write IP list of result to targetIP.txt ..."
  cat ip-grepable.txt | awk '/open/ {print $2}' | cat >> targetIP.txt && rm ip-grepable.txt
  fuINFO "Found $(cat targetIP.txt | wc -l) IP address(es) with status \"Up\""
}

function fuPrepareTargetPort {
  fuINFO "Prepare scan result ..."
  cat $1 | awk '/ open / {print $1}' | awk -F\/ '{print $1}' | cat > targetPort.txt
  fuINFO "Found $(cat targetPort.txt | wc -l) open port(s)"
}

function fuPrepareTargetPortAppend {
  fuINFO "Prepare scan result ..."
  cat $1 | awk '/ open / {print $1}' | awk -F\/ '{print $1}' | cat >> targetPort.txt
  fuINFO "Found $(cat targetPort.txt | wc -l) open port(s)"
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

if [ ! -d "output/network-infos" ]; then
  fuINFO "Creating \"./output/network-infos\" directory"
  mkdir -p output/network-infos && echo "[ OK ]"
  echo
fi


##############################
# DNS Properties/Enumeration #
##############################

# Passive Reconnaissance
# WHOIS
if [ "$DOMAIN" != "" ]; then
  fuTITLE "Searching for whois information of $DOMAIN ..."
  whois $DOMAIN | tee $myWHOISFILE

elif [ "$IP" != "" ]; then
  fuTITLE "Searching for whois information of $IP ..."
  whois $IP | tee -a $myWHOISFILE
fi

# Active Reconnaissance
# DNS enumeration
# dnsenum
if [ "$DOMAIN" != "" ]; then
  fuTITLE "Searching DNS information (host addresses, nameservers, subdomains, ...) about $DOMAIN ..."
  dnsenum $DOMAIN --nocolor | tee -a $myDNSFILE
fi

# AMASS
#if [ "$DOMAIN" != "" ]; then
#  fuTITLE "Searching subdomains for $DOMAIN ..."
#  amass enum -ipv4 -brute -d $DOMAIN | tee -a $myDNSFILE
#elif [ "$DOMAIN" != "" ] && [ "$NETDEVICE" != "" ]; then
#  fuTITLE "Searching subdomains for $DOMAIN through $NETDEVICE ..."
#  amass enum -ipv4 -brute -d $DOMAIN -iface $NETDEVICE | tee -a $myDNSFILE
#fi


#######################
# Link Layer Scanning #
#######################

# ARP scan (Link Layer)
# netdiscover !!!Network range must be 0.0.0.0/8 , /16 or /24 !!!
fuTITLE "Discover network addresses using ARP requests ..."
if [ "$IAMROOT" ]; then
  if [ "$IPRANGE" != "" ] && [ "$NETDEVICE" == "" ]; then
    netdiscover -r$IPRANGE -P | tee $myNETADDRFILE

  elif [ "$IPRANGE" != "" ] && [ "$NETDEVICE" != "" ]; then
    netdiscover -r$IPRANGE -i$NETDEVICE -P | tee $myNETADDRFILE
  fi
else
  fuERROR "You're not root. Netdiscover needs root privileges. Try \"sudo $0\""
fi

# traceroute, check if needed?


################
# IP Addresses #
################

# ICMP Scan (Network Layer)
# fping
if [ "$IP" != "" ] && [ "$NETDEVICE" == "" ]; then
  fuTITLE "ICMP check if IP address $IP is reachable ..."
  fping -s $IP | tee -a $myNETADDRFILE

elif [ "$IP" != "" ] && [ "$NETDEVICE" != "" ]; then
  fuTITLE "ICMP check if IP address $IP is reachable ..."
  fping -s $IP -I $NETDEVICE | tee -a $myNETADDRFILE

elif [ "$IP" == "" ] && [ "$NETDEVICE" != "" ] && [ "$IPRANGE" != "" ]; then
  fuTITLE "ICMP check which IP addresses of range $IPRANGE are reachable ..."
  fping -asgq $IPRANGE -I $NETDEVICE | tee -a $myNETADDRFILE

elif [ "$IP" == "" ] && [ "$NETDEVICE" == "" ] && [ "$IPRANGE" != "" ]; then
  fuTITLE "ICMP check which IP addresses of range $IPRANGE are reachable ..."
  fping -asgq $IPRANGE | tee -a $myNETADDRFILE
fi


###############################
# Network Security Appliances #
###############################

# identifies and fingerprints Web Application Firewall (WAF)
# wafw00f
if [ "$DOMAIN" != "" ]; then
  fuTITLE "Identifying Web Application Firewalls in front of $DOMAIN using HTTP requests ..."
  wafw00f -a $DOMAIN -o $mySECAPPLFILE
fi

# nmap
# waf detection with nmap --script http-waf-detect
if [ "$IP" != "" ]; then
  fuTITLE "Nmap HTTP WAF scan of $IP ..."
  nmap -Pn --script http-waf-detect $IP -oN $mySECAPPLFILE $SPOOFINGPARAMETERS | awk -v RS= '/^Nmap.*waf.*/'

elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ]; then
  fuTITLE "Nmap HTTP WAF scan of $DOMAIN ..."
  nmap -Pn --script http-waf-detect $DOMAIN -oN $mySECAPPLFILE --append-output $SPOOFINGPARAMETERS | awk -v RS= '/^Nmap.*waf.*/'

elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ]; then
  fuTITLE "Nmap HTTP WAF scan of $IPRANGE ..."
  nmap --script http-waf-detect $IPRANGE -oN $mySECAPPLFILE $SPOOFINGPARAMETERS | awk -v RS= '/^Nmap.*waf.*/'
fi

# load balancing detection
# lbd
# todo, check if needed?


#################
# DHCP Scanning #
#################

fuTITLE "Nmap DHCP discover scan, DHCP request to broadcast 255.255.255.255 ..."
if [ "$IAMROOT" ]; then
  nmap --script broadcast-dhcp-discover -oN $myDHCPFILE $SPOOFINGPARAMETERS
else
  fuERROR "You're not root. Script \"broadcast-dhcp-discover\" needs root privileges. Try \"sudo $0\""
fi


#################
# Port Scanning #
#################

# TCP scan (default scan) (Transport Layer)
# Maybe Exotic Scan Flags
# nmap
if [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$ALLPORTS" != true ]; then
  fuNmapTCPScan $IP
  fuPrepareTargetPort $myPORTFILE
  fuNmapExoticScan $IP

elif [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$ALLPORTS" == true ]; then
  fuNmapTCPScan $IP -p- -T5
  fuPrepareTargetPort $myPORTFILE
  fuNmapExoticScan $IP -p- -T5

elif [ "$IP" != "" ] && [ "$TCPPORT" != "" ]; then
  fuNmapTCPScan $IP -p$TCPPORT
  fuPrepareTargetPort $myPORTFILE
  fuNmapExoticScan $IP -p$TCPPORT

elif [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  fuNmapTCPScan $IP -p$PORTRANGE
  fuPrepareTargetPort $myPORTFILE
  fuNmapExoticScan $IP -p$PORTRANGE


# TCP Scan IP range
elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$ALLPORTS" != true ]; then
  fuNmapTCPScanIPRANGE $IPRANGE
  fuPrepareTargetIP
  fuNmapExoticScan $IPRANGE

elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$ALLPORTS" == true ]; then
  fuNmapTCPScanIPRANGE $IPRANGE -p- -T5
  fuPrepareTargetIP
  fuNmapExoticScan $IPRANGE -p- -T5

elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ] && [ "$TCPPORT" != "" ]; then
  fuNmapTCPScanIPRANGE $IPRANGE -p$TCPPORT
  fuPrepareTargetIP
  fuNmapExoticScan $IPRANGE -p$TCPPORT

elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  fuNmapTCPScanIPRANGE $IPRANGE -p$PORTRANGE
  fuPrepareTargetIP
  fuNmapExoticScan $IPRANGE -p$PORTRANGE


# TCP Scan Domain
elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$ALLPORTS" != true ]; then
  fuNmapTCPScan $DOMAIN
  fuPrepareTargetPort $myPORTFILE
  fuNmapExoticScan $DOMAIN

elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$ALLPORTS" == true ]; then
  fuNmapTCPScan $DOMAIN -p- -T5
  fuPrepareTargetPort $myPORTFILE
  fuNmapExoticScan $DOMAIN -p- -T5

elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$TCPPORT" != "" ]; then
  fuNmapTCPScan $DOMAIN -p$TCPPORT
  fuPrepareTargetPort $myPORTFILE
  fuNmapExoticScan $DOMAIN -p$TCPPORT

elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  fuNmapTCPScan $DOMAIN -p$PORTRANGE
  fuPrepareTargetPort $myPORTFILE
  fuNmapExoticScan $DOMAIN -p$PORTRANGE
fi

# UDP scan
# nmap
if [ "$UDP" ]; then
  if [ "$IP" != "" ] && [ "$UDPPORT" != "" ]; then
    fuNmapUDPScan $IP -p$UDPPORT
    fuPrepareTargetPort $myUPORTFILE

  elif [ "$IP" != "" ] && [ "$UDPPORT" == "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" == "" ]; then
    fuNmapUDPScan $IP
    fuPrepareTargetPortAppend $myUPORTFILE

  elif [ "$IP" != "" ] && [ "$UDPPORT" == "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
    fuNmapUDPScan $IP -p$PORTRANGE
    fuPrepareTargetPortAppend $myUPORTFILE

  elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ] && [ "$UDPPORT" != "" ]; then
    fuNmapUDPScanIPRANGE $IPRANGE -p$UDPPORT
    fuPrepareTargetIPAppend

  elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$UDPPORT" != "" ]; then
    fuNmapUDPScan $DOMAIN -p$UDPPORT
    fuPrepareTargetPort $myUPORTFILE

  elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$UDPPORT" == "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
    fuNmapUDPScan $DOMAIN -p$PORTRANGE
    fuPrepareTargetPortAppend $myUPORTFILE
  fi
fi


#####################
# Summarize results #
#####################

fuTITLE "Findings in following files:"

if [ -s $myDNSFILE ]; then
  fuRESULT "DNS information: $myDNSFILE"
fi
if [ -s $myNETADDRFILE ]; then
  fuRESULT "Network address information: $myNETADDRFILE"
fi
if [ -s "$mySECAPPLFILE" ]; then
  fuRESULT "Security Appliances information: $mySECAPPLFILE"
fi
if [ -s "$myDHCPFILE" ]; then
  fuRESULT "DHCP information: $myDHCPFILE"
fi
if [ -s "$myPORTFILE" ]; then
  fuRESULT "Port information: $myPORTFILE"
fi
if [ -s "targetPort.txt" ]; then
  fuRESULT "List of all open ports: targetPort.txt"
fi
if [ -s "targetIP.txt" ]; then
  fuRESULT "List of all IP addresses with open ports: targetIP.txt"
fi

if [ ! -s $myDNSFILE ] && [ ! -s $myNETADDRFILE ] && [ ! -s "$mySECAPPLFILE" ] && [ ! -s "$myDHCPFILE" ] && [ ! -s "$myPORTFILE" ]; then
  fuERROR "No network information found."
fi
echo