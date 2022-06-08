#!/bin/bash
# Reconnaissance

####################
# Global variables #
####################

DEPENDENCIES="toilet macchanger"

# colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC="\033[0m" # No Color
# bold
BRED='\033[1;31m'
BGREEN='\033[1;32m'
BYELLOW='\033[1;33m'
BBLUE='\033[1;34m'
# text
BOLD=$(tput bold)
NORMAL='\033[0;39m'


#############
# Functions #
#############

# Print banner
function print_banner {
  echo
  toilet -tf standard $1 -F metal
  echo
}

function print_advisory {
  echo
  echo -e "${BYELLOW}Advisory: ${BBLUE}Use this script for educational purposes and/or for authorized penetration testing only. The author is not responsible for any misuse or damage caused by this script. Use at your own risk.$NC"
  echo
}

# Print title
function print_title {
  echo
  for i in $(seq 80); do
    echo -en "$BBLUE═$NC"
  done
  echo
  echo -e "$BGREEN $1 $NC"
  for i in $(seq 80); do
    echo -en "$BBLUE═$NC"
  done
  echo
}

# Print info line
function print_info {
  echo
  echo -e "$BBLUE════$BGREEN $1 $NC"
}

# Print error line
function print_error {
  echo
  echo -e "$BBLUE════$BRED $1 $NC"
}

# Print results line
function print_result {
  echo
  echo -e "$BBLUE════$BYELLOW $1 $NC"
}

# Print next step line
function print_step {
  echo
  echo -e "$BBLUE[X]$NC $1 $NC"
}

# Print message line
function print_message {
  echo -e "$BBLUE----$NC $1 $NC"
}

# Print attention message line
function print_attention {
  echo -e "$BLUE----$YELLOW $1 $NC"
}

# Check for root permissions
function check_root {
print_info "Checking for root"
if ([ -f /usr/bin/id ] && [ "$(/usr/bin/id -u)" -eq "0" ]) || [ "`whoami 2>/dev/null`" = "root" ]; then
  IAMROOT="1"
  print_message "You are root"
  echo
else
  IAMROOT=""
  print_message "You are not root"
  echo
fi
}

# Check internet connection
function check_inet {
if wget -q --tries=10 --timeout=20 --spider http://google.com; then
  INET="1"
  print_message "Internet connection: $BGREEN[ OK ]$NC"
else
  INET=""
  print_message "Internet connection: $BRED[ NOT OK ]$NC"
fi
}

# Install dependencies
function install_deps {
  print_info "Upgrading packages"
  apt -y update
  print_info "Installing dependencies"
  apt -y install $DEPENDENCIES
}

function fuNmapSpoofingParameters {
  if [ "$NETDEVICE" != "" ] && [ "$SOURCEIP" != "" ] && [ "$SOURCEPORT" != "" ]; then
    echo "-e$NETDEVICE -S$SOURCEIP -g$SOURCEPORT"
  elif [ "$NETDEVICE" != "" ] && [ "$SOURCEIP" != "" ] && [ "$SOURCEPORT" == "" ]; then
    echo "-e$NETDEVICE -S$SOURCEIP"
  elif [ "$NETDEVICE" != "" ] && [ "$SOURCEIP" == "" ] && [ "$SOURCEPORT" != "" ]; then
    echo "-e$NETDEVICE -g$SOURCEPORT"
  elif [ "$NETDEVICE" != "" ] && [ "$SOURCEIP" == "" ] && [ "$SOURCEPORT" == "" ]; then
    echo "-e$NETDEVICE"
  elif [ "$NETDEVICE" == "" ] && [ "$SOURCEIP" != "" ] && [ "$SOURCEPORT" != "" ]; then
    echo "-S$SOURCEIP -g$SOURCEPORT"
  elif [ "$NETDEVICE" == "" ] && [ "$SOURCEIP" != "" ] && [ "$SOURCEPORT" == "" ]; then
    echo "-S$SOURCEIP"
  elif [ "$NETDEVICE" == "" ] && [ "$SOURCEIP" == "" ] && [ "$SOURCEPORT" != "" ]; then
    echo "-g$SOURCEPORT"
  else
    echo ""
  fi
}

function change_mac {
  if [ "$NETDEVICE" == "" ]; then
    print_error "Set a network device in \"$myCONF_FILE\" of which you would like to change the MAC address"
    echo
    exit
  elif [ ! "$IAMROOT" ]; then
    print_error "Change MAC address needs root privileges. Try \"sudo $0\""
    echo
    exit
  else
    if macchanger -r $NETDEVICE; then
      print_info "MAC address changed successfully"
      print_attention "Attention, after changing the MAC address, there could be connection problems"
      print_message "To reset the MAC to the original, permanent hardware MAC, type: macchanger -p <device>"
    fi
  fi
}


####################################
# Check the command line arguments #
####################################

PASSED_ARGS=$@
if [ "$PASSED_ARGS" != "" ]; then
  while getopts "hc:" opt; do
    case "$opt" in
      h|\?)
        echo
        echo "Usage: $0 [-h] [-c]"
        echo
        echo "-c <Path to \"reconnaissance.conf\">"
        echo "  Use this to execute the reconnaissance script."
        echo "  A configuration example is available in \"reconnaissance/reconnaissance.conf.dist\"."
        echo
        exit;;
      c) myCONF_FILE=$OPTARG;;
      esac
  done
else
  echo "$0: no configuration file given. Try -h for help."
  echo
  exit
fi

# If a valid config file exists, load the configuration
if [ "$myCONF_FILE" == "" ]; then
  echo "$0: no configuration file given. Try -h for help."
  echo
  exit
fi
if [ -s "$myCONF_FILE" ] && [ "$myCONF_FILE" != "" ]; then
  if [ "$(head -n 1 $myCONF_FILE | grep -c "# reconnaissance")" == "1" ]; then
    source "$myCONF_FILE"
  else
	  echo "Aborting. Config file \"$myCONF_FILE\" not a reconnaissance configuration file."
    echo
    exit
  fi
elif ! [ -s "$myCONF_FILE" ] && [ "$myCONF_FILE" != "" ]; then
  echo "Aborting. Config file \"$myCONF_FILE\" not found."
  echo
  exit
fi


#########################################
# Banner, Advisory, Check for root, ... #
#########################################

print_banner "RECONNAISSANCE"
print_advisory
check_root
sleep 1


################################
# Installation of Dependencies #
################################

if [ "$IAMROOT" ]; then
  check_inet
  if [ "$INET" ]; then
    install_deps
  else
    print_message "Installation of dependencies skipped."
  fi
else
  print_message "Not root. Installation of dependencies skipped."
fi


#########################################
# Check variables in configuration file #
#########################################

if [ "$IDENTITY" ] || [ "$NETWORK" ] || [ "$HOST" ] || [ "$VULN" ]; then
  print_title "Following parts will be executed:"
  if [ "$IDENTITY" ]; then
    print_message "Identity Scanning"
  fi
  if [ "$NETWORK" ]; then
    print_message "Network Scanning"
  fi
  if [ "$HOST" ]; then
    print_message "Host Scanning"
  fi
  if [ "$VULN" ]; then
    print_message "Vulnerability Scanning"
  fi
else
  print_error "Aborting. No main variable in \"$myCONF_FILE\" set to true. Nothing to do."
  print_info "Specify your configuration in \"$myCONF_FILE\" and run script again."
  echo
  exit
fi
sleep 3


########################
# Spoofing and Evasion #
########################

# set nmap spoofing variable
SPOOFINGPARAMETERS=$(fuNmapSpoofingParameters)

# change MAC address
if [ "$CHANGEMAC" ]; then
  print_title "Changing MAC address ..."
  change_mac
fi
sleep 2


######################
# Validate variables #
######################

# BETA!!!
if [ "$IP" != "" ] && ! expr "${IP}" : '^\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\)$' &>/dev/null; then
  print_error "Aborting. Invalid IPv4, check \"$myCONF_FILE\"."
  echo
  exit
fi
if [ "$IPRANGE" != "" ] && ! expr "${IPRANGE}" : '^\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\/[0-9]\{1,2\}\)$' &>/dev/null; then
  print_error "Aborting. Invalid IP Range, check \"$myCONF_FILE\"."
  echo
  exit
fi
if [ "$TCPPORT" != "" ] && ! expr "${TCPPORT}" : '^\([0-9]\{1,5\}\)$' &>/dev/null; then
  print_error "Aborting. Invalid TCP Port, check \"$myCONF_FILE\"."
  echo
  exit
fi
if [ "$UDPPORT" != "" ] && ! expr "${UDPPORT}" : '^\([0-9]\{1,5\}\)$' &>/dev/null; then
  print_error "Aborting. Invalid UDP Port, check \"$myCONF_FILE\"."
  echo
  exit
fi
if [ "$PORTRANGE" != "" ] && ! expr "${PORTRANGE}" : '^\([0-9]\{1,5\}\-[0-9]\{1,5\}\)$' &>/dev/null; then
  print_error "Aborting. Invalid Port Range, check \"$myCONF_FILE\"."
  echo
  exit
fi
if [ "$DOMAIN" != "" ] && ! expr "${DOMAIN}" : '^\(\([[:alnum:]-]\{1,63\}\.\)*[[:alpha:]]\{2,6\}\)$' &>/dev/null; then
  print_error "Aborting. Invalid Domain / URL, check \"$myCONF_FILE\"."
  echo
  exit
fi


###############################
# Gather Identity Information #
###############################

if [ "$IDENTITY" ]; then
  print_banner "Gather Identity Information ..."
  source ./parts/identity-information.sh
fi


##############################
# Gather Network Information #
##############################

if [ "$NETWORK" ]; then
  print_banner "Gather Network Information ..."
  source ./parts/network-scanning.sh
fi


###########################
# Gather Host Information #
###########################

if [ "$HOST" ]; then
  print_banner "Gather Host Information ..."
  if [ "$IP" != "" ] || [ "$DOMAIN" != "" ]; then
    source ./parts/host-scanning.sh
  else
    print_error "No IP or Domain is set in \"$myCONF_FILE\". Host Scanning is not executed!"
  fi
fi


####################################
# Gather Vulnerability Information #
####################################

if [ "$VULN" ]; then
  print_banner "Gather Vulnerability Information ..."
  if [ "$IP" != "" ] || [ "$DOMAIN" != "" ]; then
    if [ ! -s "targetPort.txt" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ]; then
      echo
      print_attention "Attention! Neither a port is specified in \"$myCONF_FILE\" nor the \"targetPort.txt\" file exists. Don't run Vulnerability Scanning without Network Scanning or without a specified port. The Vuln Scanning takes data from the Network Scanning about open ports."
      echo
    fi
    source ./parts/vulnerability-scanning.sh
  else
    print_error "No IP or Domain is set in \"$myCONF_FILE\". Vulnerability Scanning is not executed!"
  fi
fi


##############
# Next Steps #
##############

print_banner "Next Steps To Do ..."

if [ -s "targetIP.txt" ] && [ "$IP" == "" ]; then
  print_step "There are IP addresses with open ports! Set one of these specific IP address in \"$myCONF_FILE\" to gather more detailed information."
fi

if [ "$IP" == "" ]; then
  print_step "No specific IP set. Try to set a specific IP address to gather more detailed information."
fi

if [ ! "$VULN" ]; then
  print_step "No vulnerability information gathered. Try set \"VULN\" variable to true and run script again."
elif [ ! "$NETWORK" ] && [ "$TCPPORT" == "" ] && [ "$UDPPORT" == "" ]; then
  echo
  print_attention "Attention! Neither a port is specified in \"$myCONF_FILE\" nor the \"NETWORK\" variable set to true. Don't run Vulnerability Scanning without Network Scanning or without a specified port, unless you've already run it once. The Vuln Scanning takes data from the Network Scanning about open ports."
fi

print_step "Search for possible vulnerabilities in directory $BYELLOW\"output/\"$NC."
print_step "Check the $BYELLOW../exploitation/README.md$NC file on how to find exploits."

if [ -s "$myVULNFILEXML" ]; then
  print_step "Set SEARCHEXPLOIT variable in the $BYELLOW../exploitation/exploitation.conf$NC file to true to let the exploitation script find exploits from nmap vulners scan."
fi

echo