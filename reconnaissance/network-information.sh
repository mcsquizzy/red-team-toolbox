#!/bin/bash
# Gather Network Information

####################
# Global variables #
####################

DEPENDENCIES="whois dnsenum amass python3-dnspython fping netdiscover nmap"

#############
# Functions #
#############

function fuWhois {
  echo
  echo "Searching for whois information of $1 ..."
  echo
  whois $1 | tee -a dns-stats.txt
}

function fuArpScan {
  echo
  echo "Discover network addresses using ARP requests ..."
  echo
  netdiscover -P $1 $2 | tee -a arp-stats.txt
}


# NMAP Scans
function fuNmapSynScan {
  echo
  echo "SYN (Half-open) scan of $1 ..."
  echo
  nmap -oN port-stats.txt $1 $2 $3
}

function fuNmapSynScanIPRANGE {
  echo
  echo "SYN (Half-open) scan of $1 ... (might take some time)"
  echo
  nmap -oG port-stats.txt --min-hostgroup=64 $1 $2 $3
}

function fuNmapUDPScan {
  echo
  echo "UDP Scan of $1 ..."
  echo
  nmap -sU -oN uport-stats.txt $1 $2
}

function fuNmapUDPScanIPRANGE {
  echo
  echo "UDP scan of IP Range $IPRANGE and Port $UDPPORT ..."
  echo
  nmap -sU -oG port-stats.txt --append-output
}


# Print scan result to usable list
function fuPrepareTargetIP {
  echo
  echo "print ip list of result to targetIP.txt"
  echo
  cat port-stats.txt | awk '/Up/ {print $2}' | cat >> targetIP.txt
}

function fuPrepareTargetPort {
  echo
  echo "print port list of result to targetPort.txt"
  echo
  cat port-stats.txt | awk '/open/ {print $1}' | awk -F\/ '{print $1}' | tr '\n' , | cat >> targetPort.txt
}

function fuPrepareTargetUPort {
  echo
  echo "print port list of result to targetPort.txt"
  echo
  cat uport-stats.txt | awk '/open/ {print $1}' | awk -F\/ '{print $1}' | tr '\n' , | cat >> targetPort.txt
}


################################
# Installation of Dependencies #
################################

fuGET_DEPS


###########################
# Domain / DNS Properties #
###########################

# Passive Reconnaissance
# WHOIS
if [ "$DOMAIN" != "" ]; then
  fuWhois $DOMAIN

elif [ "$IP" != "" ]; then
  fuWhois $IP

fi

# Active Reconnaissance
# DNS enumeration
# dnsenum
if [ "$DOMAIN" != "" ]; then
  echo
  echo "Searching information (host addresses, nameservers, subdomains, ...) about $DOMAIN ..."
  echo
  dnsenum $DOMAIN --nocolor | tee -a dns-stats.txt
fi

# AMASS
if [ "$DOMAIN" != "" ]; then
  echo
  echo "Searching subdomains for $DOMAIN ..."
  echo
  amass enum -ip -brute -d $DOMAIN | tee -a dns-stats.txt
fi

# check if needed
#Dirbuster
#Gobuster
 


#######################
# Link Layer Scanning #
#######################

# ARP scan (Link Layer)
# netdiscover !!!Network range must be 0.0.0.0/8 , /16 or /24 !!!
if [ "$IPRANGE" != "" ] && [ "$NETDEVICE" == "" ]; then
  fuArpScan -r$IPRANGE

elif [ "$IPRANGE" != "" ] && [ "$NETDEVICE" != "" ]; then
  fuArpScan -r$IPRANGE -i$NETDEVICE

elif [ "$NETDEVICE" != "" ] && [ "$IPRANGE" == "" ] ; then
  fuArpScan -i$NETDEVICE

fi

# traceroute
# check if needed?


################
# IP Addresses #
################

# ICMP Scan (Network Layer)
# fping
if [ "$IP" != "" ]; then
  echo
  echo "Check if ip address $IP is reachable ..."
  echo
  fping -s $IP | tee -a ip-alive.txt
elif [ "$IPRANGE" != "" ]; then
  echo
  echo "Check which ip addresses of range $IPRANGE are reachable ..."
  echo
  fping -asg $IPRANGE | tee -a ip-alive.txt
fi


###############################
# Network Security Appliances #
###############################

# identifies and fingerprints Web Application Firewall (WAF)
# wafw00f
if [ "$DOMAIN" != "" ]; then
  echo
  echo "Identifying Web Application Firewalls in front of $DOMAIN ..."
  echo
  wafw00f -a $DOMAIN -o sec-appliances-stats.txt
fi

# load balancing detection
# lbd
# todo, check if needed?



#################
# Port Scanning #
#################

# TCP SYN scan (default scan) (Transport Layer)
# nmap
# Syn scan IP
if [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" == "" ]; then
  fuNmapSynScan $IP
  fuPrepareTargetPort

elif [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$ALLPORTS" == true ]; then
  fuNmapSynScan $IP -p-
  fuPrepareTargetPort

elif [ "$IP" != "" ] && [ "$TCPPORT" != "" ]; then
  fuNmapSynScan $IP -p$TCPPORT
  fuPrepareTargetPort

elif [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  fuNmapSynScan $IP -p$PORTRANGE
  fuPrepareTargetPort

# Syn Scan IP range
elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$ALLPORTS" == false ]; then
  fuNmapSynScanIPRANGE $IPRANGE
  fuPrepareTargetIP

elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$ALLPORTS" == true ]; then
  fuNmapSynScanIPRANGE $IPRANGE -p- -T5
  fuPrepareTargetIP

elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ] && [ "$TCPPORT" != "" ]; then
  fuNmapSynScanIPRANGE $IPRANGE -p$TCPPORT
  fuPrepareTargetIP

elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  fuNmapSynScanIPRANGE $IPRANGE -p$PORTRANGE
  fuPrepareTargetIP

# Syn Scan Domain
elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$ALLPORTS" == false ]; then
  fuNmapSynScan $DOMAIN
  fuPrepareTargetPort

elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$ALLPORTS" == true ]; then
  fuNmapSynScan $DOMAIN -p-
  fuPrepareTargetPort

elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$TCPPORT" != "" ]; then
  fuNmapSynScan $DOMAIN -p$TCPPORT
  fuPrepareTargetPort

elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  fuNmapSynScan $DOMAIN -p$PORTRANGE
  fuPrepareTargetPort

fi

# neak through certain non-stateful firewalls and packet filtering routers
# TCP FIN scan

# TCP Xmas scan



# UDP scan
# nmap
if [ "$IP" != "" ] && [ "$UDPPORT" != "" ]; then
  fuNmapUDPScan $IP -p$UDPPORT
  fuPrepareTargetUPort

elif [ "$IP" != "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" == "" ]; then
  fuNmapUDPScan $IP
  fuPrepareTargetUPort

elif [ "$IP" != "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  fuNmapUDPScan $IP -p$PORTRANGE
  fuPrepareTargetUPort

elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ] && [ "$UDPPORT" != "" ]; then
  fuNmapUDPScanIPRANGE $IPRANGE -p$UDPPORT
  fuPrepareTargetIP

elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$UDPPORT" != "" ]; then
  fuNmapUDPScan $DOMAIN -p$UDPPORT
  fuPrepareTargetUPort

elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  fuNmapUDPScan $DOMAIN -p$PORTRANGE
  fuPrepareTargetUPort

fi
