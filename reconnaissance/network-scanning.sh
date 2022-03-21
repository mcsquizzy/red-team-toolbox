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
  fuMESSAGE "Searching for whois information of $1 ..."
  whois $1 | tee -a dns-stats.txt
}

function fuArpScan {
  fuMESSAGE "Discover network addresses using ARP requests ..."
  netdiscover $1 $2 -P | tee -a arp-stats.txt
}


# NMAP Scans
function fuNmapSynScan {
  fuMESSAGE "TCP SYN (Half-open) scan of $1 $2..."
  nmap -sS -Pn -oN port-stats.txt $1 $2 $3
}

function fuNmapSynScanIPRANGE {
  fuMESSAGE "TCP SYN (Half-open) scan of $1 $2... (might take some time)"
  nmap -sS -Pn -T4 --min-hostgroup=64 -oN port-stats.txt -oG ip-grepable.txt $1 $2 $3
}

function fuNmapUDPScan {
  fuMESSAGE "UDP Scan of $1 $2..."
  nmap -sU -Pn -T5 -oN uport-stats.txt $1 $2
}

function fuNmapUDPScanIPRANGE {
  fuMESSAGE "UDP scan of $1 $2..."
  nmap -sU -Pn -T5 -oN port-stats.txt --append-output -oG ip-grepable.txt $1 $2
}


# Print scan result to usable list
function fuPrepareTargetIP {
  fuMESSAGE "print ip list of result to targetIP.txt ..."
  cat ip-grepable.txt | awk '/Up/ {print $2$3}' | cat >> targetIP.txt #&& rm ip-grepable.txt
  fuMESSAGE "found $(cat targetIP.txt | wc -l) IP addresses with status \"Up\""
  cat targetIP.txt
}

function fuPrepareTargetPort {
  fuMESSAGE "print port list of result to targetPort.txt ..."
  cat $1 | awk '/open/ {print $1}' | awk -F\/ '{print $1}' | cat >> targetPort.txt
  fuMESSAGE "found $(cat targetPort.txt | wc -l) open ports"
  cat targetPort.txt
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
  fuMESSAGE "Searching information (host addresses, nameservers, subdomains, ...) about $DOMAIN ..."
  dnsenum $DOMAIN --nocolor | tee -a dns-stats.txt
fi

# AMASS
if [ "$DOMAIN" != "" ]; then
  fuMESSAGE "Searching subdomains for $DOMAIN ..."
  amass enum -ipv4 -brute -d $DOMAIN | tee -a dns-stats.txt

elif [ "$DOMAIN" != "" ] && [ "$NETDEVICE" != "" ]; then
  fuMESSAGE "Searching subdomains for $DOMAIN through $NETDEVICE ..."
  amass enum -ipv4 -brute -d $DOMAIN -iface $NETDEVICE | tee -a dns-stats.txt

fi



#######################
# Link Layer Scanning #
#######################

# ARP scan (Link Layer)
# netdiscover !!!Network range must be 0.0.0.0/8 , /16 or /24 !!!
if [ "$IPRANGE" != "" ] && [ "$NETDEVICE" == "" ]; then
  fuArpScan -r$IPRANGE

elif [ "$IPRANGE" != "" ] && [ "$NETDEVICE" != "" ]; then
  fuArpScan -r$IPRANGE -i$NETDEVICE

elif [ "$IPRANGE" == "" ] && [ "$NETDEVICE" != "" ]; then
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
  fuMESSAGE "Check if ip address $IP is reachable ..."
  fping -s $IP | tee ip-alive.txt

elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ]; then
  fuMESSAGE "Check which ip addresses of range $IPRANGE are reachable ..."
  fping -asg $IPRANGE -q | tee ip-alive.txt

fi


###############################
# Network Security Appliances #
###############################

# identifies and fingerprints Web Application Firewall (WAF)
# wafw00f
if [ "$DOMAIN" != "" ]; then
  fuMESSAGE "Identifying Web Application Firewalls in front of $DOMAIN ..."
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
if [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$ALLPORTS" == false ]; then
  fuNmapSynScan $IP
  fuPrepareTargetPort port-stats.txt

elif [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$ALLPORTS" == true ]; then
  fuNmapSynScan $IP -p- -T5
  fuPrepareTargetPort port-stats.txt

elif [ "$IP" != "" ] && [ "$TCPPORT" != "" ]; then
  fuNmapSynScan $IP -p$TCPPORT
  fuPrepareTargetPort port-stats.txt

elif [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  fuNmapSynScan $IP -p$PORTRANGE
  fuPrepareTargetPort port-stats.txt

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
  fuPrepareTargetPort port-stats.txt

elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$ALLPORTS" == true ]; then
  fuNmapSynScan $DOMAIN -p- -T5
  fuPrepareTargetPort port-stats.txt

elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$TCPPORT" != "" ]; then
  fuNmapSynScan $DOMAIN -p$TCPPORT
  fuPrepareTargetPort port-stats.txt

elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  fuNmapSynScan $DOMAIN -p$PORTRANGE
  fuPrepareTargetPort port-stats.txt

fi

# neak through certain non-stateful firewalls and packet filtering routers
# TCP FIN scan

# TCP Xmas scan



# UDP scan
# nmap
if [ "$IP" != "" ] && [ "$UDPPORT" != "" ]; then
  fuNmapUDPScan $IP -p$UDPPORT
  fuPrepareTargetPort uport-stats.txt

elif [ "$IP" != "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$TCPPORT" == "" ]; then
  fuNmapUDPScan $IP
  fuPrepareTargetPort uport-stats.txt

elif [ "$IP" != "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  fuNmapUDPScan $IP -p$PORTRANGE
  fuPrepareTargetPort uport-stats.txt

elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ] && [ "$UDPPORT" != "" ]; then
  fuNmapUDPScanIPRANGE $IPRANGE -p$UDPPORT
  fuPrepareTargetIP

elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$UDPPORT" != "" ]; then
  fuNmapUDPScan $DOMAIN -p$UDPPORT
  fuPrepareTargetPort uport-stats.txt

elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  fuNmapUDPScan $DOMAIN -p$PORTRANGE
  fuPrepareTargetPort uport-stats.txt

fi
