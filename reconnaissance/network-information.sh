#!/bin/bash
# Gather Network Information

####################
# Global variables #
####################

DEPENDENCIES="whois dnsenum amass python3-dnspython fping netdiscover nmap"

#############
# Functions #
#############

function fuNmapSynScanIP {
  echo
  echo "SYN (Half-open) scan of IP $1 and the top most common 1000 ports ..."
  echo
  nmap -oN port-stats.txt $1
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


#######################
# Link Layer Scanning #
#######################

# ARP scan (Link Layer)
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
if [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" == "" ]; then
  fuNmapSynScanIP $IP
  fuPrepareTargetPort

elif [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$ALLPORTS" == true ]; then
  echo
  echo "SYN (Half-open) scan of IP $IP and all ports ..."
  echo
  nmap $IP -p- -oN port-stats.txt
  fuPrepareTargetPort

elif [ "$IP" != "" ] && [ "$TCPPORT" != "" ]; then
  echo
  echo "SYN (Half-open) scan of IP $IP and port $TCPPORT ..."
  echo
  nmap $IP -p $TCPPORT -oN port-stats.txt
  fuPrepareTargetPort

elif [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  echo
  echo "SYN (Half-open) scan of IP $IP and port range $PORTRANGE ..."
  echo
  nmap $IP -p $PORTRANGE -oN port-stats.txt
  fuPrepareTargetPort

elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$ALLPORTS" == false ]; then
  echo
  echo "SYN (Half-open) scan of IP range $IPRANGE and the top most common 1000 ports ... (might take some time)"
  echo
  nmap $IPRANGE --min-hostgroup=64 -oG port-stats.txt
  fuPrepareTargetIP

elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$ALLPORTS" == true ]; then
  echo
  echo "SYN (Half-open) scan of IP range $IPRANGE and all ports ... (might take some time)"
  echo
  nmap $IPRANGE -p- -T5 -oG port-stats.txt
  fuPrepareTargetIP

elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ] && [ "$TCPPORT" != "" ]; then
  echo
  echo "SYN (Half-open) scan of IP range $IPRANGE and port $TCPPORT ..."
  echo
  nmap $IPRANGE -p $TCPPORT --min-hostgroup=64 -oG port-stats.txt
  fuPrepareTargetIP

elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  echo
  echo "SYN (Half-open) scan of IP range $IPRANGE and port range $PORTRANGE ... (might take some time)"
  echo
  nmap $IPRANGE -p $PORTRANGE --min-hostgroup=64 oG port-stats.txt
  fuPrepareTargetIP

elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$ALLPORTS" == false ]; then
  echo
  echo "SYN (Half-open) scan of domain $DOMAIN and the top most common 1000 ports ..."
  echo
  nmap $DOMAIN -oN port-stats.txt
  fuPrepareTargetPort

elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$ALLPORTS" == true ]; then
  echo
  echo "SYN (Half-open) scan of domain $DOMAIN and all ports ... (might take some time)"
  echo
  nmap $DOMAIN -p- -oN port-stats.txt
  fuPrepareTargetPort

elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$TCPPORT" != "" ]; then
  echo
  echo "SYN (Half-open) scan of domain $DOMAIN and port $TCPPORT ..."
  echo
  nmap $DOMAIN -p $TCPPORT -oN port-stats.txt
  fuPrepareTargetPort

elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  echo
  echo "SYN (Half-open) scan of domain $DOMAIN and port range $PORTRANGE ..."
  echo
  nmap $DOMAIN -p $PORTRANGE -oN port-stats.txt
  fuPrepareTargetPort

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
  nmap -sU -p $UDPPORT $IP -oN uport-stats.txt
  fuPrepareTargetUPort

elif [ "$IP" != "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" == "" ]; then
  echo
  echo "UDP Scan of IP $IP and the top most common 1000 ports ..."
  echo
  nmap -sU $IP -oN uport-stats.txt
  fuPrepareTargetUPort

elif [ "$IP" != "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  echo
  echo "UDP scan of IP $IP and Portrange $PORTRANGE ..."
  echo
  nmap -sU -p $PORTRANGE $IP -oN uport-stats.txt
  fuPrepareTargetUPort

elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ] && [ "$UDPPORT" != "" ]; then
  echo
  echo "UDP scan of IP Range $IPRANGE and Port $UDPPORT ..."
  echo
  nmap -sU -p $UDPPORT $IPRANGE -oG port-stats.txt --append-output
  fuPrepareTargetIP

elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$UDPPORT" != "" ]; then
  echo
  echo "UDP scan of Domain $DOMAIN and Port $UDPPORT ..."
  echo
  nmap -sU -p $UDPPORT $DOMAIN -oN uport-stats.txt
  fuPrepareTargetUPort

elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  echo
  echo "UDP scan of Domain $DOMAIN and Portrange $PORTRANGE ..."
  echo
  nmap -sU -p $PORTRANGE $DOMAIN -oN uport-stats.txt
  fuPrepareTargetUPort

fi
