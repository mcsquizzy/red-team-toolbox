#!/bin/bash
# Gather Network Information

####################
# Global variables #
####################

DEPENDENCIES="whois dnsmap python3-dnspython fping"


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
# dnsmap (for subdomains)
if [ "$DOMAIN" != "" ]; then
  echo "Searching (sub)domains for $DOMAIN ..."
  dnsmap $DOMAIN | tee -a dns-stats.txt
fi

# dnsenum, dnsrecon




################
# IP Addresses #
################

# check if ip address is reachable
if [ "$IP" != "" ]; then
  echo "Check if ip address $IP is reachable ..."
  fping -s $IP | tee -a ip-stats.txt
elif [ "$IPRANGE" != "" ]; then
  echo "Check which ip addresses of range $IPRANGE are reachable ..."
  fping -asg $IPRANGE | tee -a ip-stats.txt
fi


