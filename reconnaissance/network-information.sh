#!/bin/bash
# Gather Network Information

####################
# Global variables #
####################

DEPENDENCIES="whois dnsenum amass python3-dnspython fping netdiscover nmap"

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
  echo
  echo "Searching for whois information of $DOMAIN ..."
  echo
  whois $DOMAIN | tee -a dns-stats.txt
elif [ "$IP" != "" ]; then
  echo
  echo "Searching for whois information of $IP ..."
  echo
  whois $IP | tee -a dns-stats.txt
fi

# Active Reconnaissance
# DNS enumeration
# dnsenum
if [ "$DOMAIN" != "" ]; then
  echo
  echo "Searching information (host addresses, nameservers, subdomains, ...) about $DOMAIN ..."
  echo
  dnsenum $DOMAIN --noreverse | tee -a dns-stats.txt
fi

# AMASS
if [ "$DOMAIN" != "" ]; then
  echo
  echo "Searching subdomains for $DOMAIN ..."
  echo
  amass enum -ip -brute -d $DOMAIN | tee -a dns-stats.txt
fi


################
# IP Addresses #
################

# ICMP Scan
# fping
if [ "$IP" != "" ]; then
  echo
  echo "Check if ip address $IP is reachable ..."
  echo
  fping -s $IP | tee -a ip-stats.txt
elif [ "$IPRANGE" != "" ]; then
  echo
  echo "Check which ip addresses of range $IPRANGE are reachable ..."
  echo
  fping -asg $IPRANGE | tee -a ip-stats.txt
fi


####################
# Network Topology #
####################

# ARP scan
# netdiscover !!!Network range must be 0.0.0.0/8 , /16 or /24 !!!
if [ "$IPRANGE" != "" ] && [ "$NETDEVICE" == "" ]; then
  echo
  echo "Discover network addresses using ARP requests from $IPRANGE ..."
  echo
  netdiscover -P -r $IPRANGE | tee -a arp-stats.txt
elif [ "$IPRANGE" != "" ] && [ "$NETDEVICE" != "" ]; then
  echo
  echo "Discover network addresses using ARP requests from $IPRANGE out of $NETDEVICE ..."
  echo
  netdiscover -P -i $NETDEVICE -r $IPRANGE | tee -a arp-stats.txt
elif [ "$NETDEVICE" != "" ] && [ "$IPRANGE" == "" ] ; then
  echo
  echo "Discover network addresses using ARP requests out of $NETDEVICE ..."
  echo
  netdiscover -P -i $NETDEVICE | tee -a arp-stats.txt
fi

# traceroute
# todo, check if needed?


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

# TCP SYN scan
# nmap
if [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" == "" ]; then
  echo
  echo "SYN (Half-open) scan of IP $IP and the top most common 1000 ports ..."
  echo
  nmap -sS $IP -oG port-stats.txt --append-output
elif [ "$IP" != "" ] && [ "$TCPPORT" != "" ]; then
  echo
  echo "SYN (Half-open) scan of IP $IP and Port $TCPPORT ..."
  echo
  nmap -sS -p $TCPPORT $IP -oG port-stats.txt --append-output
elif [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  echo
  echo "SYN (Half-open) scan of IP $IP and Portrange $PORTRANGE ..."
  echo
  nmap -sS -p $PORTRANGE $IP -oG port-stats.txt --append-output
elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" == "" ]; then
  echo
  echo "SYN (Half-open) scan of IP Range $IPRANGE and the top most common 1000 ports ..."
  echo
  nmap -sS $IPRANGE -oG port-stats.txt --append-output
elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ] && [ "$TCPPORT" != "" ]; then
  echo
  echo "SYN (Half-open) scan of IP Range $IPRANGE and Port $TCPPORT ..."
  echo
  nmap -sS -p $TCPPORT $IPRANGE -oG port-stats.txt --append-output
elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" == "" ]; then
  echo
  echo "SYN (Half-open) scan of Domain $DOMAIN and the top most common 1000 ports ..."
  echo
  nmap -sS $DOMAIN -oG port-stats.txt --append-output
elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$TCPPORT" != "" ]; then
  echo
  echo "SYN (Half-open) scan of Domain $DOMAIN and Port $TCPPORT ..."
  echo
  nmap -sS -p $TCPPORT $DOMAIN -oG port-stats.txt --append-output
elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  echo
  echo "SYN (Half-open) scan of Domain $DOMAIN and Portrange $PORTRANGE ..."
  echo
  nmap -sS -p $PORTRANGE $DOMAIN -oG port-stats.txt --append-output
fi

# neak through certain non-stateful firewalls and packet filtering routers
# TCP FIN scan

# TCP Xmas scan



# UDP scan
# nmap
if [ "$IP" != "" ] && [ "$UDPPORT" != "" ]; then
  echo
  echo "UDP Scan of IP $IP and Port $UDPPORT ..."
  echo
  nmap -sU -p $UDPPORT $IP -oG port-stats.txt --append-output
elif [ "$IP" != "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  echo
  echo "UDP scan of IP $IP and Portrange $PORTRANGE ..."
  echo
  nmap -sU -p $PORTRANGE $IP -oG port-stats.txt --append-output
elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ] && [ "$UDPPORT" != "" ]; then
  echo
  echo "UDP scan of IP Range $IPRANGE and Port $UDPPORT ..."
  echo
  nmap -sU -p $UDPPORT $IPRANGE -oG port-stats.txt --append-output
elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$UDPPORT" != "" ]; then
  echo
  echo "UDP scan of Domain $DOMAIN and Port $UDPPORT ..."
  echo
  nmap -sU -p $UDPPORT $DOMAIN -oG port-stats.txt --append-output
elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  echo
  echo "UDP scan of Domain $DOMAIN and Portrange $PORTRANGE ..."
  echo
  nmap -sU -p $PORTRANGE $DOMAIN -oG port-stats.txt --append-output
fi
