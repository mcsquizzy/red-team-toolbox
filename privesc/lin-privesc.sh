#!/bin/sh
# Linux Privilege Escalation

####################
# Global variables #
####################

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
fuBANNER() {
# http://patorjk.com/software/taag/#p=display&f=Graffiti&t=Type%20Something
echo "
  _     _                    ____       _       _ _                   _____               _       _   _             
 | |   (_)_ __  _   ___  __ |  _ \ _ __(_)_   _(_) | ___  __ _  ___  | ____|___  ___ __ _| | __ _| |_(_) ___  _ __  
 | |   | | '_ \| | | \ \/ / | |_) | '__| \ \ / / | |/ _ \/ _\` |/ _ \ |  _| / __|/ __/ _\` | |/ _\` | __| |/ _ \| '_ \ 
 | |___| | | | | |_| |>  <  |  __/| |  | |\ V /| | |  __/ (_| |  __/ | |___\__ \ (_| (_| | | (_| | |_| | (_) | | | |
 |_____|_|_| |_|\__,_/_/\_\ |_|   |_|  |_| \_/ |_|_|\___|\__, |\___| |_____|___/\___\__,_|_|\__,_|\__|_|\___/|_| |_|
                                                         |___/                                                      
"
}

# Print output title
fuTITLE() {
  echo
  echo "$BBLUE════════════════════════════════════════════════════════════════════════"
  echo "$BGREEN $1 $BBLUE"
  echo "════════════════════════════════════════════════════════════════════════$NC"
}

# Print info line
fuINFO() {
  echo
  echo "$BBLUE═══$BGREEN $1 $NC"
}

# Print error line
fuERROR() {
  echo
  echo "$BBLUE═══$BRED $1 $NC"
}

# Print results line
fuRESULT() {
  echo
  echo "$BBLUE═══$BYELLOW $1 $NC"
}

# Print next steps line
fuSTEPS() {
  echo
  echo "$BBLUE[X]$NC $1 $NC"
}

# Print message line
fuMESSAGE() {
  echo "$BBLUE---$NC $1 $NC"
}

# Check for root permissions
fuGOT_ROOT() {
#fuINFO "Checking for root"
if ([ -f /usr/bin/id ] && [ "$(/usr/bin/id -u)" -eq "0" ]) || [ "`whoami 2>/dev/null`" = "root" ]; then
  IAMROOT="1"
  fuINFO "You are already root!"
  sleep 2
  echo
else
  IAMROOT=""
  #fuMESSAGE "You are not root"
  echo
fi
}

#####################################
# Check the command line parameters #
#####################################

PASSED_ARGS=$@
if [ "$PASSED_ARGS" != "" ]; then
  while getopts "hs:" opt; do
    case "$opt" in
      h|\?)
        echo
        echo "Usage: sh $0 [-h] [-xxxx]"
        echo
        echo "-xxx <xxxxx>"
        echo "  Trying to xxxx"
        echo
        exit;;
      x) blablabla;;
      esac
  done
else
  echo "$0: no arguments passed to script. Try -h for help."
  echo
  exit
fi

# validate OPTARG 
# todo

##########
# Banner #
##########

fuBANNER
echo
echo "Disclaimer: $RED todo $NC"
echo
sleep 1

#####################
# Checking for root #
#####################

fuGOT_ROOT
sleep 1

###########
# linPEAS #
###########

#todo

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

#todo
echo