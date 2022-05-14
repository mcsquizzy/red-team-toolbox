#!/bin/sh
# Lateral Movement

####################
# Global variables #
####################

# colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color
# bold
BRED="\033[1;31m"
BGREEN="\033[1;32m"
BYELLOW="\033[1;33m"
BBLUE="\033[1;34m"
# text
BOLD="$(tput bold)"
NORMAL="\033[0;39m"

# Get hostname
hostname=`hostname 2>/dev/null`

mySYSTEMFILE="${hostname}_system_info.txt"


#############
# Functions #
#############

# Print banner
fuBANNER() {
# http://patorjk.com/software/taag/#p=display&f=Graffiti&t=Type%20Something
echo "
  _        _  _____ _____ ____      _    _       __  __  _____     _______ __  __ _____ _   _ _____ 
 | |      / \|_   _| ____|  _ \    / \  | |     |  \/  |/ _ \ \   / / ____|  \/  | ____| \ | |_   _|
 | |     / _ \ | | |  _| | |_) |  / _ \ | |     | |\/| | | | \ \ / /|  _| | |\/| |  _| |  \| | | |  
 | |___ / ___ \| | | |___|  _ <  / ___ \| |___  | |  | | |_| |\ V / | |___| |  | | |___| |\  | | |  
 |_____/_/   \_\_| |_____|_| \_\/_/   \_\_____| |_|  |_|\___/  \_/  |_____|_|  |_|_____|_| \_| |_|  
"
}

fuADVISORY() {
  echo
  echo "${BYELLOW}Advisory: ${BBLUE}Use this script for educational purposes and/or for authorized penetration testing only. The author is not responsible for any misuse or damage caused by this script. Use at your own risk.$NC"
  echo
}

# Print title
fuTITLE() {
  echo
  for i in $(seq 80); do
    echo -n "$BBLUE═$NC"
  done
  echo
  echo "$BGREEN $1 $NC"
  for i in $(seq 80); do
    echo -n "$BBLUE═$NC"
  done
  echo
}

# Print info line
fuINFO() {
  echo
  echo "$BBLUE════$BGREEN $1 $NC"
}

# Print check line
#fuCHECKS() {
#  echo
#  local title="$1"
#  echo -n "$BBLUE════ $1 $NC"
#  for i in $(seq $((${#title}+13)) 80); do
#    echo -n "."
#  done
#}

#fuOK() {
#  echo -n " $BGREEN[yes]$NC"
#  echo
#}

#fuNOTOK() {
#  echo -n "  $BRED[no]$NC"
#  echo
#}

# Print error line
fuERROR() {
  echo
  echo "$BBLUE════$BRED $1 $NC"
}

# Print results line
fuRESULT() {
  echo
  echo "$BBLUE════$NC $1"
}

# Print next steps line
fuSTEPS() {
  echo
  echo "$BBLUE[X]$NC $1 $NC"
}

# Print message line
fuMESSAGE() {
  echo "$BBLUE----$NC $1 $NC"
}

# Print attention message line
fuATTENTION() {
  echo "$BLUE----$YELLOW $1 $NC"
}

# Check for root permissions
fuGOT_ROOT() {
fuINFO "Checking for root"
if ([ -f /usr/bin/id ] && [ "$(/usr/bin/id -u)" -eq "0" ]) || [ "`whoami 2>/dev/null`" = "root" ]; then
  IAMROOT="1"
  fuMESSAGE "You are root"
  echo
else
  IAMROOT=""
  fuMESSAGE "You are not root"
  echo
fi
}


#####################################
# Check the command line parameters #
#####################################

PASSED_ARGS=$@
if [ "$PASSED_ARGS" != "" ]; then
  while getopts "h?cqw" opt; do
    case "$opt" in
      h|\?)
        echo
        echo "Options:"
        echo
        echo "-h/-?"
        echo "  Show this help message"
        echo
        echo "-c"
        echo "  No colours"
        echo "  Without colours, the output can probably be read better"
        echo
        echo "-q"
        echo "  Quiet. No banner and no advisory displayed"
        echo
        echo "-w"
        echo "  Serves an local web server for transferring files"
        echo
        exit;;
      c) NOCOLOUR="1";;
      w) SERVE="1";QUIET="1";;
      q) QUIET="1";;
      esac
  done
else
  echo "$0: no arguments passed to script. Try -h for help."
  echo
#  exit
fi

# validate OPTARG 
# todo

if [ "$NOCOLOUR" ]; then
  RED=""
  GREEN=""
  YELLOW=""
  BLUE=""
  NC=""
  BRED=""
  BGREEN=""
  BYELLOW=""
  BBLUE=""
fi


#########################################
# Banner, Advisory, Check for root, ... #
#########################################

if [ ! "$QUIET" ]; then fuBANNER; fuADVISORY; fuGOT_ROOT; fi
sleep 1


#######################
# Network Information #
#######################

# current IP(s)
fuTITLE "Current IP(s) ..."
current_ips=$(ip a | grep -vi docker | grep -Eo 'inet[^6]\S+[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{print $2}' | grep -E "^10\.|^172\.|^192\.168\.|^169\.254\." 2>/dev/null || ifconfig | grep -vi docker | grep -Eo 'inet[^6]\S+[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{print $2}' | grep -E "^10\.|^172\.|^192\.168\.|^169\.254\." 2>/dev/null)
if [ "$current_ips" ]; then
  echo "$current_ips"
else
  fuERROR "No IP(s) found"
fi

# network neighbors
# arp
fuTITLE "Neighboring network addresses from arp table (arp cache) ..."
neighbour=$(ip neigh || arp -e | grep -vi incomplete || arp -a | grep -vi incomplete) 2>/dev/null
if [ "$neighbour" ]; then
  echo "$neighbour"
else
  fuERROR "No entries in the arp cache table found"
fi

# reachable IP(s) with ping / fping
PING=$(command -v ping 2>/dev/null)
FPING=$(command -v fping 2>/dev/null)

if [ "$FPING" ]; then
  echo "$current_ips" | while read current_ip; do
    if ! [ -z "$current_ip" ]; then
      fuTITLE "Discovering hosts in $current_ip/24"
      # fping
      $FPING -asgq $current_ip/24
    fi
  done
fi



#Reconnaissance von kompromittiertem Host aus.


#first: check if nmap is installed!!
#sonst:
#nmap Binary



#SSH:
#https://highon.coffee/blog/ssh-lateral-movement-cheat-sheet/


