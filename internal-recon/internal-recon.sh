#!/bin/sh
# Internal Reconnaissance

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
hostname=`$(command -v hostname) 2>/dev/null`

mySYSTEMFILE="${hostname}_system_info.txt"
myNETWFILE="${hostname}_network_info.txt"


#############
# Functions #
#############

# Print banner
fuBANNER() {
# http://patorjk.com/software/taag/#p=display&f=Graffiti&t=Type%20Something
echo "
  ___ _   _ _____ _____ ____  _   _    _    _       ____  _____ ____ ___  _   _ _   _    _    ___ ____ ____    _    _   _  ____ _____ 
 |_ _| \ | |_   _| ____|  _ \| \ | |  / \  | |     |  _ \| ____/ ___/ _ \| \ | | \ | |  / \  |_ _/ ___/ ___|  / \  | \ | |/ ___| ____|
  | ||  \| | | | |  _| | |_) |  \| | / _ \ | |     | |_) |  _|| |  | | | |  \| |  \| | / _ \  | |\___ \___ \ / _ \ |  \| | |   |  _|  
  | || |\  | | | | |___|  _ <| |\  |/ ___ \| |___  |  _ <| |__| |__| |_| | |\  | |\  |/ ___ \ | | ___) |__) / ___ \| |\  | |___| |___ 
 |___|_| \_| |_| |_____|_| \_\_| \_/_/   \_\_____| |_| \_\_____\____\___/|_| \_|_| \_/_/   \_\___|____/____/_/   \_\_| \_|\____|_____|
                                                                                                                                      
"
}

# Print output title
fuTITLE() {
  echo
  echo "$BBLUE════════════════════════════════════════════════════════════════════════════"
  echo "$BGREEN $1 $BBLUE"
  echo "════════════════════════════════════════════════════════════════════════════$NC"
}

# Print info line
fuINFO() {
  echo
  echo "$BBLUE════$BGREEN $1 $NC"
}

# Print error line
fuERROR() {
  echo
  echo "$BBLUE════$BRED $1 $NC"
}

# Print results line
fuRESULT() {
  echo
  echo "$BBLUE════$BYELLOW $1 $NC"
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
  while getopts "h?c" opt; do
    case "$opt" in
      h|\?)
        echo
        echo "Usage: sh $0 [-h/-?] [-c]"
        echo
        echo "-h/-?"
        echo "  Show this help message"
        echo
        echo "-c"
        echo "  No colours"
        echo "  Without colours, the output can probably be read better"
        echo
        exit;;
      c) NOCOLOUR="1";;
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

##########
# Banner #
##########

fuBANNER
echo
echo "${BYELLOW}Advisory: ${BBLUE}Use this script for educational purposes and/or for authorized penetration testing only. The author is not responsible for any misuse or damage caused by this script. Use at your own risk.$NC"
echo
sleep 1

#####################
# Checking for root #
#####################

fuGOT_ROOT
sleep 1

######################
# System Information #
######################

system_info() {

fuTITLE "System Information"

fuINFO "Linux version"
versioninfo=`$(command -v cat) /etc/*-release 2>/dev/null`
if [ "$versioninfo" ]; then echo "$versioninfo"; fi

fuINFO "Kernel info"
kernelinfo=`$(command -v uname) -ar 2>/dev/null`
if [ "$kernelinfo" ]; then echo "$kernelinfo"; fi

fuINFO "Hostname"
hostname=`$(command -v hostname) 2>/dev/null`
if [ "$hostname" ]; then echo "$hostname"; fi

}

#######################
# Network Information #
#######################

network_info() {

fuTITLE "Network Information"

fuINFO "Current IP"
currentip='$(command -v ip) a | grep -vi docker | grep -Eo 'inet[^6]\S+[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{print $2}' | grep -E "^10\.|^172\.|^192\.168\.|^169\.254\." 2>/dev/null'
if [ "$currentip" ]; then
  currentip
else
  $(command -v ifconfig) | grep -vi docker | grep -Eo 'inet[^6]\S+[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{print $2}' | grep -E "^10\.|^172\.|^192\.168\.|^169\.254\." 2>/dev/null
fi

fuINFO "DNS info"
dnsinfo='grep "nameserver" /etc/resolv.conf'
if [ "$dnsinfo" ]; then $dnsinfo; fi
nsinfo='systemd-resolve --status 2>/dev/null'
if [ "$nsinfo" ]; then $nsinfo; fi

fuINFO "Route info"
defroute='$(command -v route)'
if [ "$defroute" ]; then $defroute; fi
defrouteip='$(command -v ip) r | grep default 2>/dev/null'
if [ "$defrouteip" ]; then $defrouteip; fi



}


####################
# User Information #
####################

#user_info(){}





#########################
# Environment Variables #
#########################



################
# Jobs / Tasks #
################








system_info | tee $mySYSTEMFILE



##############
# Next Steps #
##############
  
echo "
   _   _           _     ____  _                   _____       ____                
  | \ | | _____  _| |_  / ___|| |_ ___ _ __  ___  |_   _|__   |  _ \  ___          
  |  \| |/ _ \ \/ / __| \___ \| __/ _ \ '_ \/ __|   | |/ _ \  | | | |/ _ \         
  | |\  |  __/>  <| |_   ___) | ||  __/ |_) \__ \   | | (_) | | |_| | (_) |  _ _ _ 
  |_| \_|\___/_/\_\ __| |____/ \__\___| .__/|___/   |_|\___/  |____/ \___/  (_|_|_)
                                      |_|                                          
"

fuSTEPS "Next steps to do..."

echo