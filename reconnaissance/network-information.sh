#!/bin/bash
# Gather Network Information

####################
# Global variables #
####################

DEPENDENCIES="whois dnsenum amass python3-dnspython fping netdiscover nmap"


#############
# Functions #
#############

# Install dependencies
#function fuGET_DEPS {
#    echo
#    echo "### Installing dependencies"
#    echo
#    apt -y install $DEPENDENCIES
#}


################################
# Installation of Dependencies #
################################

fuGET_DEPS


###########################
# Domain / DNS Properties #
###########################

# WHOIS
if [ "$DOMAIN" != "" ]; then
  echo "Searching for whois information of $DOMAIN ..."
  whois $DOMAIN | tee -a dns-stats.txt
elif [ "$IP" != "" ]; then
  echo "Searching for whois information of $IP ..."
  whois $IP | tee -a dns-stats.txt
fi

# DNS enumeration
# dnsenum
if [ "$DOMAIN" != "" ]; then
  echo "Searching information (host addresses, nameservers, subdomains, ...) about $DOMAIN ..."
  dnsenum $DOMAIN --noreverse | tee -a dns-stats.txt
fi

# AMASS
if [ "$DOMAIN" != "" ]; then
  echo "Searching subdomains for $DOMAIN ..."
  amass enum -ip -brute -d $DOMAIN | tee -a dns-stats.txt
fi



################
# IP Addresses #
################

# simple pings (ICMP requests and responses)
if [ "$IP" != "" ]; then
  echo "Check if ip address $IP is reachable ..."
  fping -s $IP | tee -a ip-stats.txt
elif [ "$IPRANGE" != "" ]; then
  echo "Check which ip addresses of range $IPRANGE are reachable ..."
  fping -asg $IPRANGE | tee -a ip-stats.txt
fi


####################
# Network Topology #
####################

# netdiscover
if [ "$IPRANGE" != "" ] && [ "$NETDEVICE" == "" ]; then
  echo "Discover network addresses using ARP requests from $IPRANGE ..."
  netdiscover -r $IPRANGE -P | tee -a net-stats.txt
elif [ "$IPRANGE" != "" ] && [ "$NETDEVICE" != "" ]; then
  echo "Discover network addresses using ARP requests from $IPRANGE out of $NETDEVICE ..."
  netdiscover -i $NETDEVICE -r $IPRANGE -P | tee -a net-stats.txt
elif [ "$NETDEVICE" != "" ] && [ "$IPRANGE" == "" ] ; then
  echo "Discover network addresses using ARP requests out of $NETDEVICE ..."
  netdiscover -i $NETDEVICE -P | tee -a net-stats.txt
fi



###############################
# Network Security Appliances #
###############################




###################
# Active Scanning #
###################

# Port Scanning (TCP)
# nmap
if [ "$IP" != "" ] && [ "$PORT" == "" ]; then
  echo "Simple TCP Port Scan of IP $IP and all Ports ..."
  nmap -v -sT -p- $IP -oN port-stats.txt
elif [ "$IP" != "" ] && [ "$PORT" != "" ]; then
  echo "Simple TCP Port Scan of IP $IP and Port $PORT ..."
  nmap -v -sT -p $PORT $IP -oN port-stats.txt
elif [ "$IP" != "" ] && [ "$PORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  echo "Simple TCP Port Scan of IP $IP and Portrange $PORTRANGE ..."
  nmap -v -sT -p $PORTRANGE $IP -oN port-stats.txt
elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ] && [ "$PORT" == "" ]; then
  echo "Simple TCP Port Scan of IP Range $IPRANGE and all Ports ..."
  nmap -v -sT -p- $IPRANGE -oN port-stats.txt
elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ] && [ "$PORT" != "" ]; then
  echo "Simple TCP Port Scan of IP Range $IPRANGE and Port $PORT ..."
  nmap -v -sT -p $PORT $IPRANGE -oN port-stats.txt
# scan time with DOMAIN too long!
#elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$PORT" == "" ]; then
#  echo "Simple TCP Port Scan of Domain $DOMAIN and all Ports ..."
#  nmap -v -sT -p- $DOMAIN -oN port-stats.txt
elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$PORT" != "" ]; then
  echo "Simple TCP Port Scan of Domain $DOMAIN and Port $PORT ..."
  nmap -v -sT -p $PORT $DOMAIN -oN port-stats.txt
elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$PORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  echo "Simple TCP Port Scan of Domain $DOMAIN and Portrange $PORTRANGE ..."
  nmap -v -sT -p $PORTRANGE $DOMAIN -oN port-stats.txt
fi



# Vulnerability Scanning
# nikto






