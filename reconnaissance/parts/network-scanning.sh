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
function nmap_tcp_scan {
  print_title "Nmap TCP SYN scan of $* ..."
  if [ "$IAMROOT" ]; then
    nmap -sS -Pn -oN $myPORTFILE $SPOOFINGPARAMETERS $*
  else
    print_error "You're not root. TCP SYN scan needs root privileges. Try \"sudo $0\""
  fi
}

function nmap_tcp_scan_iprange {
  print_title "Nmap TCP SYN scan of $* ... (might take some time)"
  if [ "$IAMROOT" ]; then
    nmap -sS -T4 --min-hostgroup=64 -oN $myPORTFILE -oG ip-grepable.txt $SPOOFINGPARAMETERS $*
  else
    print_error "You're not root. TCP SYN scan needs root privileges. Try \"sudo $0\""
  fi
}

function nmap_udp_scan {
  print_title "Nmap UDP scan of $* ..."
  if [ "$IAMROOT" ]; then
    nmap -sU -Pn -sV --version-light -T4 -oN $myUPORTFILE $SPOOFINGPARAMETERS $* --host-timeout 120s
  else
    print_error "You're not root. UDP scan needs root privileges. Try \"sudo $0\""
  fi
}

function nmap_udp_scan_iprange {
  print_title "Nmap UDP scan of $* ... (might take some time)"
  if [ "$IAMROOT" ]; then
    nmap -sU -sV --version-light -T5 -oN $myPORTFILE --append-output -oG ip-grepable.txt $SPOOFINGPARAMETERS $* --host-timeout 120s
  else
    print_error "You're not root. UDP scan needs root privileges. Try \"sudo $0\""
  fi
}

# neak through certain non-stateful firewalls and packet filtering routers
function nmap_exotic_scan {
  if grep -q -w filtered $myPORTFILE; then
    print_info "Target might be behind a firewall, trying Exotic Scan Flags"
    if [ "$IAMROOT" ]; then
      nmap_fin_scan $*
    else
      print_error "You're not root. Exotic scan needs root privileges. Try \"sudo $0\""
    fi
  fi
}

# FIN scan (-sF), Sets just the TCP FIN bit.
# open|filtered = No response received, port might be open
# IDS and IPS Evasion (https://book.hacktricks.xyz/pentesting/pentesting-network/ids-evasion)
function nmap_fin_scan {
  print_title "Nmap FIN scan of $* ..."
  nmap -sF -Pn -oN $myPORTFILE --append-output $SPOOFINGPARAMETERS $* --data-length 25 -f
}

# Null scan (-sN), Does not set any bits (TCP flag header is 0)
function nmap_null_scan {
  print_title "Nmap NULL scan of $* ..."
  nmap -sN -Pn -oN $myPORTFILE --append-output $SPOOFINGPARAMETERS $* --data-length 25 -f
}


# Print scan result to usable list
function prepare_target_ip {
  print_info "Write IP list of result to targetIP.txt ..."
  cat ip-grepable.txt | awk '/open/ {print $2}' | cat > targetIP.txt && rm ip-grepable.txt
  print_info "Found $(cat targetIP.txt | wc -l) IP address(es) with status \"Up\""
}

function prepare_target_ip_append {
  print_info "Write IP list of result to targetIP.txt ..."
  cat ip-grepable.txt | awk '/open/ {print $2}' | cat >> targetIP.txt && rm ip-grepable.txt
  print_info "Found $(cat targetIP.txt | wc -l) IP address(es) with status \"Up\""
}

function prepare_target_port {
  print_info "Prepare scan result ..."
  cat $1 | awk '/ open / {print $1}' | awk -F\/ '{print $1}' | cat > targetPort.txt
  print_info "Found $(cat targetPort.txt | wc -l) open port(s)"
}

function prepare_target_port_append {
  print_info "Prepare scan result ..."
  cat $1 | awk '/ open / {print $1}' | awk -F\/ '{print $1}' | cat >> targetPort.txt
  print_info "Found $(cat targetPort.txt | wc -l) open port(s)"
}


################################
# Installation of Dependencies #
################################

if [ "$IAMROOT" ] && [ "$INET" ]; then
  install_deps
else
  print_message "Installation of dependencies skipped."
fi


###########################
# Create output directory #
###########################

if [ ! -d "output/network-infos" ]; then
  print_info "Creating \"./output/network-infos\" directory"
  mkdir -p output/network-infos && echo "[ OK ]"
  echo
fi


##############################
# DNS Properties/Enumeration #
##############################

# Passive Reconnaissance
# WHOIS
if [ "$DOMAIN" != "" ]; then
  print_title "Searching for whois information of $DOMAIN ..."
  whois $DOMAIN | tee $myWHOISFILE
  # nmap
  # nmap --script whois-domain -Pn -sn

elif [ "$IP" != "" ]; then
  print_title "Searching for whois information of $IP ..."
  whois $IP | tee -a $myWHOISFILE
  # nmap
  # nmap --script whois-ip -Pn -sn
fi

# Active Reconnaissance
# DNS enumeration
# dnsenum
if [ "$DOMAIN" != "" ]; then
  print_title "Searching DNS information (host addresses, nameservers, subdomains, ...) about $DOMAIN ..."
  dnsenum $DOMAIN --nocolor | tee -a $myDNSFILE
fi

# AMASS
#if [ "$DOMAIN" != "" ]; then
#  print_title "Searching subdomains for $DOMAIN ..."
#  amass enum -ipv4 -brute -d $DOMAIN | tee -a $myDNSFILE
#elif [ "$DOMAIN" != "" ] && [ "$NETDEVICE" != "" ]; then
#  print_title "Searching subdomains for $DOMAIN through $NETDEVICE ..."
#  amass enum -ipv4 -brute -d $DOMAIN -iface $NETDEVICE | tee -a $myDNSFILE
#fi


#######################
# Link Layer Scanning #
#######################

# ARP scan (Link Layer)
# netdiscover !!!Network range must be 0.0.0.0/8 , /16 or /24 !!!
print_title "Discover network addresses using ARP requests ..."
if [ "$IAMROOT" ]; then
  if [ "$IPRANGE" != "" ] && [ "$NETDEVICE" == "" ]; then
    netdiscover -r$IPRANGE -P | tee $myNETADDRFILE

  elif [ "$IPRANGE" != "" ] && [ "$NETDEVICE" != "" ]; then
    netdiscover -r$IPRANGE -i$NETDEVICE -P | tee $myNETADDRFILE
  fi
else
  print_error "You're not root. Netdiscover needs root privileges. Try \"sudo $0\""
fi


################
# IP Addresses #
################

# ICMP Scan (Network Layer)
# fping
if [ "$IP" != "" ] && [ "$NETDEVICE" == "" ]; then
  print_title "ICMP check if IP address $IP is reachable ..."
  fping -s $IP | tee -a $myNETADDRFILE

elif [ "$IP" != "" ] && [ "$NETDEVICE" != "" ]; then
  print_title "ICMP check if IP address $IP is reachable ..."
  fping -s $IP -I $NETDEVICE | tee -a $myNETADDRFILE

elif [ "$IP" == "" ] && [ "$NETDEVICE" != "" ] && [ "$IPRANGE" != "" ]; then
  print_title "ICMP check which IP addresses of range $IPRANGE are reachable ..."
  fping -asgq $IPRANGE -I $NETDEVICE | tee -a $myNETADDRFILE

elif [ "$IP" == "" ] && [ "$NETDEVICE" == "" ] && [ "$IPRANGE" != "" ]; then
  print_title "ICMP check which IP addresses of range $IPRANGE are reachable ..."
  fping -asgq $IPRANGE | tee -a $myNETADDRFILE
fi


###############################
# Network Security Appliances #
###############################

# identifies and fingerprints Web Application Firewall (WAF)
# wafw00f
if [ "$DOMAIN" != "" ]; then
  print_title "Identifying Web Application Firewalls in front of $DOMAIN using HTTP requests ..."
  wafw00f -a $DOMAIN -o $mySECAPPLFILE
fi

# nmap
# waf detection with nmap --script http-waf-detect
if [ "$IP" != "" ]; then
  print_title "Nmap HTTP WAF scan of $IP ..."
  nmap -Pn --script http-waf-detect $IP -oN $mySECAPPLFILE $SPOOFINGPARAMETERS --host-timeout 60s | awk -v RS= '/^Nmap.*waf.*/'

elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ]; then
  print_title "Nmap HTTP WAF scan of $DOMAIN ..."
  nmap -Pn --script http-waf-detect $DOMAIN -oN $mySECAPPLFILE --append-output $SPOOFINGPARAMETERS --host-timeout 60s | awk -v RS= '/^Nmap.*waf.*/'

elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ]; then
  print_title "Nmap HTTP WAF scan of $IPRANGE ..."
  nmap --script http-waf-detect $IPRANGE -oN $mySECAPPLFILE $SPOOFINGPARAMETERS --host-timeout 60s | awk -v RS= '/^Nmap.*waf.*/'
fi

# load balancing detection
# lbd
# todo, check if needed?


#################
# DHCP Scanning #
#################

print_title "Nmap DHCP discover scan, DHCP request to broadcast 255.255.255.255 ..."
if [ "$IAMROOT" ]; then
  nmap --script broadcast-dhcp-discover -oN $myDHCPFILE $SPOOFINGPARAMETERS
else
  print_error "You're not root. Script \"broadcast-dhcp-discover\" needs root privileges. Try \"sudo $0\""
fi


#################
# Port Scanning #
#################

# TCP scan (default scan) (Transport Layer)
# Maybe Exotic Scan Flags
# nmap
if [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$ALLPORTS" != true ]; then
  nmap_tcp_scan $IP
  prepare_target_port $myPORTFILE
  nmap_exotic_scan $IP

elif [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$ALLPORTS" == true ]; then
  nmap_tcp_scan $IP -p- -T5
  prepare_target_port $myPORTFILE
  nmap_exotic_scan $IP -p- -T5

elif [ "$IP" != "" ] && [ "$TCPPORT" != "" ]; then
  nmap_tcp_scan $IP -p$TCPPORT
  prepare_target_port $myPORTFILE
  nmap_exotic_scan $IP -p$TCPPORT

elif [ "$IP" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  nmap_tcp_scan $IP -p$PORTRANGE
  prepare_target_port $myPORTFILE
  nmap_exotic_scan $IP -p$PORTRANGE


# TCP Scan IP range
elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$ALLPORTS" != true ]; then
  nmap_tcp_scan_iprange $IPRANGE
  prepare_target_ip
  nmap_exotic_scan $IPRANGE

elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$ALLPORTS" == true ]; then
  nmap_tcp_scan_iprange $IPRANGE -p- -T5
  prepare_target_ip
  nmap_exotic_scan $IPRANGE -p- -T5

elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ] && [ "$TCPPORT" != "" ]; then
  nmap_tcp_scan_iprange $IPRANGE -p$TCPPORT
  prepare_target_ip
  nmap_exotic_scan $IPRANGE -p$TCPPORT

elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  nmap_tcp_scan_iprange $IPRANGE -p$PORTRANGE
  prepare_target_ip
  nmap_exotic_scan $IPRANGE -p$PORTRANGE


# TCP Scan Domain
elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$ALLPORTS" != true ]; then
  nmap_tcp_scan $DOMAIN
  prepare_target_port $myPORTFILE
  nmap_exotic_scan $DOMAIN

elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" == "" ] && [ "$ALLPORTS" == true ]; then
  nmap_tcp_scan $DOMAIN -p- -T5
  prepare_target_port $myPORTFILE
  nmap_exotic_scan $DOMAIN -p- -T5

elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$TCPPORT" != "" ]; then
  nmap_tcp_scan $DOMAIN -p$TCPPORT
  prepare_target_port $myPORTFILE
  nmap_exotic_scan $DOMAIN -p$TCPPORT

elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
  nmap_tcp_scan $DOMAIN -p$PORTRANGE
  prepare_target_port $myPORTFILE
  nmap_exotic_scan $DOMAIN -p$PORTRANGE
fi

# UDP scan
# nmap
if [ "$UDP" ]; then
  if [ "$IP" != "" ] && [ "$UDPPORT" != "" ]; then
    nmap_udp_scan $IP -p$UDPPORT
    prepare_target_port $myUPORTFILE

  elif [ "$IP" != "" ] && [ "$UDPPORT" == "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" == "" ]; then
    nmap_udp_scan $IP
    prepare_target_port_append $myUPORTFILE

  elif [ "$IP" != "" ] && [ "$UDPPORT" == "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
    nmap_udp_scan $IP -p$PORTRANGE
    prepare_target_port_append $myUPORTFILE

  elif [ "$IP" == "" ] && [ "$IPRANGE" != "" ] && [ "$UDPPORT" != "" ]; then
    nmap_udp_scan_iprange $IPRANGE -p$UDPPORT
    prepare_target_ip_append

  elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$UDPPORT" != "" ]; then
    nmap_udp_scan $DOMAIN -p$UDPPORT
    prepare_target_port $myUPORTFILE

  elif [ "$IP" == "" ] && [ "$DOMAIN" != "" ] && [ "$UDPPORT" == "" ] && [ "$TCPPORT" == "" ] && [ "$PORTRANGE" != "" ]; then
    nmap_udp_scan $DOMAIN -p$PORTRANGE
    prepare_target_ip_append $myUPORTFILE
  fi
fi


#####################
# Summarize results #
#####################

print_title "Findings in following files:"

if [ -s $myDNSFILE ]; then
  print_result "DNS information: $myDNSFILE"
fi
if [ -s $myNETADDRFILE ]; then
  print_result "Network address information: $myNETADDRFILE"
fi
if [ -s "$mySECAPPLFILE" ]; then
  print_result "Security Appliances information: $mySECAPPLFILE"
fi
if [ -s "$myDHCPFILE" ]; then
  print_result "DHCP information: $myDHCPFILE"
fi
if [ -s "$myPORTFILE" ]; then
  print_result "Port information: $myPORTFILE"
fi
if [ -s "targetPort.txt" ]; then
  print_result "List of all open ports: targetPort.txt"
fi
if [ -s "targetIP.txt" ]; then
  print_result "List of all IP addresses with open ports: targetIP.txt"
fi

if [ ! -s $myDNSFILE ] && [ ! -s $myNETADDRFILE ] && [ ! -s "$mySECAPPLFILE" ] && [ ! -s "$myDHCPFILE" ] && [ ! -s "$myPORTFILE" ]; then
  print_error "No network information found."
fi
echo