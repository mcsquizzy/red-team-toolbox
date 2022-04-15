#!/bin/bash
# Gather Network Information

####################
# Global variables #
####################

DEPENDENCIES="whois dnsenum amass python3-dnspython fping netdiscover nmap"
myDNSFILE="output/dns-findings.txt"
myWHOISFILE="output/whois-findings.txt"
myNETADDRFILE="output/net-addr-findings.txt"
mySECAPPLFILE="output/sec-appliance-findings.txt"
myPORTFILE="output/port-findings.txt"
myUPORTFILE="output/uport-findings.txt"


#############
# Functions #
#############

# NMAP Scans
function fuNmapSynScan {
  fuTITLE "TCP SYN (Half-open) scan of $* ..."
  nmap -sS -Pn -oN $myPORTFILE $SPOOFINGPARAMETERS $*
}

function fuNmapSynScanIPRANGE {
  fuTITLE "TCP SYN (Half-open) scan of $* ... (might take some time)"
  nmap -sS -T4 --min-hostgroup=64 -oN $myPORTFILE -oG ip-grepable.txt $SPOOFINGPARAMETERS $*
}

function fuNmapUDPScan {
  fuTITLE "UDP Scan of $* ..."
  nmap -sU -Pn -sV --version-light -T4 -oN $myUPORTFILE $SPOOFINGPARAMETERS $* --host-timeout 120s
}

function fuNmapUDPScanIPRANGE {
  fuTITLE "UDP scan of $* ... (might take some time)"
  nmap -sU -sV --version-light -T5 -oN $myPORTFILE --append-output -oG ip-grepable.txt $SPOOFINGPARAMETERS $* --host-timeout 120s
}

# neak through certain non-stateful firewalls and packet filtering routers
function fuNmapExoticScan {
  if grep -q -w filtered $myPORTFILE; then
    fuINFO "Target might be behind a firewall, trying Exotic Scan Flags"
    fuNmapFINScan $*
  fi
}

# FIN scan (-sF), Sets just the TCP FIN bit.
# open|filtered = No response received, port might be open
# IDS and IPS Evasion (https://book.hacktricks.xyz/pentesting/pentesting-network/ids-evasion)
function fuNmapFINScan {
  fuTITLE "FIN scan of $* ..."
  nmap -sF -Pn -oN $myPORTFILE --append-output $SPOOFINGPARAMETERS $* --data-length 25 -f
}

# Null scan (-sN), Does not set any bits (TCP flag header is 0)
function fuNmapNULLScan {
  fuTITLE "NULL scan of $* ..."
  nmap -sN -Pn -oN $myPORTFILE --append-output $SPOOFINGPARAMETERS $* --data-length 25 -f
}


# Print scan result to usable list
function fuPrepareTargetIP {
  fuINFO "Write ip list of result to targetIP.txt ..."
  cat ip-grepable.txt | awk '/open/ {print $2$3}' | cat > targetIP.txt #&& rm ip-grepable.txt
  fuINFO "Found $(cat targetIP.txt | wc -l) IP address(es) with status \"Up\""
}

function fuPrepareTargetIPAppend {
  fuINFO "Write ip list of result to targetIP.txt ..."
  cat ip-grepable.txt | awk '/open/ {print $2$3}' | cat >> targetIP.txt #&& rm ip-grepable.txt
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

fuGET_DEPS

###########################
# Create output directory #
###########################

if [ ! -d "output/" ]; then
  fuINFO "creating \"output/\" directory"
  mkdir output && echo "[ OK ]"
fi

###########################
# Domain / DNS Properties #
###########################

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
  fuTITLE "Searching information (host addresses, nameservers, subdomains, ...) about $DOMAIN ..."
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
if [ "$IPRANGE" != "" ] && [ "$NETDEVICE" == "" ]; then
  fuTITLE "Discover network addresses using ARP requests ..."
  netdiscover -r$IPRANGE -P | tee $myNETADDRFILE

elif [ "$IPRANGE" != "" ] && [ "$NETDEVICE" != "" ]; then
  fuTITLE "Discover network addresses using ARP requests ..."
  netdiscover -r$IPRANGE -i$NETDEVICE -P | tee $myNETADDRFILE

fi

# traceroute
# check if needed?


################
# IP Addresses #
################

# ICMP Scan (Network Layer)
# fping
if [ "$IP" != "" ] && [ "$NETDEVICE" == "" ]; then
  fuTITLE "Check if ip address $IP is reachable ..."
  fping -s $IP | tee -a $myNETADDRFILE

elif [ "$IP" != "" ] && [ "$NETDEVICE" != "" ]; then
  fuTITLE "Check if ip address $IP is reachable ..."
  fping -s $IP -I $NETDEVICE | tee -a $myNETADDRFILE

elif [ "$IP" == "" ] && [ "$NETDEVICE" != "" ] && [ "$IPRANGE" != "" ]; then
  fuTITLE "Check which ip addresses of range $IPRANGE are reachable ..."
  fping -asg $IPRANGE -I $NETDEVICE -q | tee -a $myNETADDRFILE

elif [ "$IP" == "" ] && [ "$NETDEVICE" == "" ] && [ "$IPRANGE" != "" ]; then
  fuTITLE "Check which ip addresses of range $IPRANGE are reachable ..."
  fping -asg $IPRANGE -q | tee -a $myNETADDRFILE

fi


###############################
# Network Security Appliances #
###############################

# identifies and fingerprints Web Application Firewall (WAF)
# wafw00f
if [ "$DOMAIN" != "" ]; then
  fuTITLE "Identifying Web Application Firewalls in front of $DOMAIN ..."
  wafw00f -a $DOMAIN -o $mySECAPPLFILE
fi

# load balancing detection
# lbd
# todo, check if needed?
# waf detection with nmap --script http-waf-*


#################
# Port Scanning #
#################

# TCP SYN scan (default scan) (Transport Layer)
# Maybe Exotic Scan Flags
# nmap
if [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$ALLPORTS" != true ]; then
  fuNmapSynScan $IP
  fuPrepareTargetPort $myPORTFILE
  fuNmapExoticScan $IP

elif [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$ALLPORTS" == true ]; then
  fuNmapSynScan $IP -p- -T5
  fuPrepareTargetPort $myPORTFILE
  fuNmapExoticScan $IP -p- -T5

elif [ "$IP" != "" ] && [ "$TCPPORT" != "" ]; then
  fuNmapSynScan $IP -p$TCPPORT
  fuPrepareTargetPort $myPORTFILE
  fuNmapExoticScan $IP -p$TCPPORT

elif [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  fuNmapSynScan $IP -p$PORTRANGE
  fuPrepareTargetPort $myPORTFILE
  fuNmapExoticScan $IP -p$PORTRANGE

# Syn Scan IP range
elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$ALLPORTS" != true ]; then
  fuNmapSynScanIPRANGE $IPRANGE
  fuPrepareTargetIP
  fuNmapExoticScan $IPRANGE

elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$ALLPORTS" == true ]; then
  fuNmapSynScanIPRANGE $IPRANGE -p- -T5
  fuPrepareTargetIP
  fuNmapExoticScan $IPRANGE -p- -T5

elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ] && [ "$TCPPORT" != "" ]; then
  fuNmapSynScanIPRANGE $IPRANGE -p$TCPPORT
  fuPrepareTargetIP
  fuNmapExoticScan $IPRANGE -p$TCPPORT

elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  fuNmapSynScanIPRANGE $IPRANGE -p$PORTRANGE
  fuPrepareTargetIP
  fuNmapExoticScan $IPRANGE -p$PORTRANGE

# Syn Scan Domain
#elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$ALLPORTS" != true ]; then
#  fuNmapSynScan $DOMAIN
#  fuPrepareTargetPort $myPORTFILE

#elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$ALLPORTS" == true ]; then
#  fuNmapSynScan $DOMAIN -p- -T5
#  fuPrepareTargetPort $myPORTFILE

#elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$TCPPORT" != "" ]; then
#  fuNmapSynScan $DOMAIN -p$TCPPORT
#  fuPrepareTargetPort $myPORTFILE

#elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
#  fuNmapSynScan $DOMAIN -p$PORTRANGE
#  fuPrepareTargetPort $myPORTFILE

fi


# UDP scan
# nmap
if [ "$UDP" == true ]; then
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

  #elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$UDPPORT" != "" ]; then
  #  fuNmapUDPScan $DOMAIN -p$UDPPORT
  #  fuPrepareTargetPort $myUPORTFILE

  #elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$UDPPORT" == "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  #  fuNmapUDPScan $DOMAIN -p$PORTRANGE
  #  fuPrepareTargetPortAppend $myUPORTFILE
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
if [ -s "$myPORTFILE" ]; then
  fuRESULT "Port information: $myPORTFILE"
fi
if [ -s "targetPort.txt" ]; then
  fuRESULT "List of all open ports: targetPort.txt"
fi
if [ -s "targetIP.txt" ]; then
  fuRESULT "List of all ip addresses with open ports: targetIP.txt"
fi
if [ ! -s $myDNSFILE ] && [ ! -s $myNETADDRFILE ] && [ ! -s "$mySECAPPLFILE" ] && [ ! -s "$myPORTFILE" ]; then
  fuERROR "No network information found."
fi
echo