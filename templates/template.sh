#!/bin/sh
# Template Shell Script

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
  _____ _____ __  __ ____  _        _  _____ _____   ____   ____ ____  ___ ____ _____ 
 |_   _| ____|  \/  |  _ \| |      / \|_   _| ____| / ___| / ___|  _ \|_ _|  _ \_   _|
   | | |  _| | |\/| | |_) | |     / _ \ | | |  _|   \___ \| |   | |_) || || |_) || |  
   | | | |___| |  | |  __/| |___ / ___ \| | | |___   ___) | |___|  _ < | ||  __/ | |  
   |_| |_____|_|  |_|_|   |_____/_/   \_\_| |_____| |____/ \____|_| \_\___|_|    |_|  
                                                                                                                                                                                                                                                      
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

# Print attention message line
fuATTENTION() {
  echo "$BLUE---$YELLOW $1 $NC"
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
  while getopts "h" opt; do
    case "$opt" in
      h|\?)
        echo
        echo "Usage: sh $0 [-h]"
        echo
        exit;;
      esac
  done
else
  echo "$0: no arguments passed to script. Try -h for help."
  echo
#  exit
fi

# validate OPTARG 
# todo


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


#############
# Parts ... #
#############



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