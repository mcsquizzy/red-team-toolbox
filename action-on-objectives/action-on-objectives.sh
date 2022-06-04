#!/bin/sh
# Action on Objectives

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


#############
# Functions #
#############

# Print banner
print_banner() {
# http://patorjk.com/software/taag/#p=display&f=Graffiti&t=Type%20Something
echo "
     _    ____ _____ ___ ___  _   _    ___  _   _    ___  ____      _ _____ ____ _____ _____     _______ ____  
    / \  / ___|_   _|_ _/ _ \| \ | |  / _ \| \ | |  / _ \| __ )    | | ____/ ___|_   _|_ _\ \   / / ____/ ___| 
   / _ \| |     | |  | | | | |  \| | | | | |  \| | | | | |  _ \ _  | |  _|| |     | |  | | \ \ / /|  _| \___ \ 
  / ___ \ |___  | |  | | |_| | |\  | | |_| | |\  | | |_| | |_) | |_| | |__| |___  | |  | |  \ V / | |___ ___) |
 /_/   \_\____| |_| |___\___/|_| \_|  \___/|_| \_|  \___/|____/ \___/|_____\____| |_| |___|  \_/  |_____|____/ 
                                                                                                               
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
  echo "$BBLUE════$NC $1"
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
  while getopts "h?a:u:e:d:wcq" opt; do
    case "$opt" in
      h|\?)
        echo
        echo "Usage: $0 [options]"
        echo 
        echo "Options:"
        echo "-h               Show this help message"
        echo "-a <file, files or directory>"
        echo "                 Archive and compress given files or directory"
        echo "                 Specify directories without the last /"
        echo "                 More than one file in quotes \"\""
        echo "-u <archive.tar.gz>"
        echo "                 Extract the given tar archive"
        echo "-e <file>        Encrypt given file"
        echo "-d <file>        Decrypt given file"
        echo
        echo "-w               Serves a local web server for transferring files"
        echo
        echo "Output:"
        echo "-c               No colours. Without colours, the output can probably be read better"
        echo "-q               Quiet. No banner and no advisory displayed"
        echo
        exit;;
      c) NOCOLOUR="1";;
      a) ARCHIVE="1";DATA=$OPTARG;;
      u) EXTRACT="1";DATATOEXTRACT=$OPTARG;;
      e) ENCRYPT="1";FILETOENCRYPT=$OPTARG;;
      d) DECRYPT="1";FILETODECRYPT=$OPTARG;;
      w) SERVE="1";QUIET="1";;
      q) QUIET="1";;
      esac
  done
else
  echo "$0: no arguments passed to script. Try -h for help."
  echo
  exit
fi

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


#######################
# Validate parameters #
#######################

if [ "$DATATOEXTRACT" != "" ] && ! expr "${DATATOEXTRACT}" : '^.*\.tar\.gz$' 1>/dev/null 2>&1; then
  print_error "Aborting. Given file not a tar archive (.tar.gz), see -h"
  echo
  exit
fi


#########################################
# Banner, Advisory, Check for root, ... #
#########################################

if [ ! "$QUIET" ]; then
  print_banner
  print_advisory
  check_root
fi
sleep 1


####################
# File compression #
####################

tar_archive() {

print_title "Create archive and compress \"$*\" ..."
sleep 1

if [ "$(command -v tar 2>/dev/null)" ]; then
  if tar czvf $1.tar.gz $* 1>/dev/null 2>&1; then
    ARCHIVEOK="1"
    CREATEDARCHIVE="$1.tar.gz"
    print_message "Archive $1.tar.gz created"
    print_message "Archive $1.tar.gz has following content:"
    tar tvf $1.tar.gz 2>/dev/null
  else
    ARCHIVEOK="" && print_error "Archive not created"
  fi
else
  print_error "command \"tar\" not found"
fi

}


######################
# Archive extraction #
######################

tar_extract() {

print_title "Extract and decompress archive \"$1\" ..."
sleep 1

if [ -e "$1" ]; then
  # file exists
  if [ "$(command -v tar 2>/dev/null)" ]; then
    if tar xzvf $1 2>/dev/null; then
      print_message "Archive $1 extracted"
    else
      print_error "Archive $1 could not be extracted"
    fi
  else
    print_error "command \"tar\" not found"
  fi
else
  # file does not exist
  print_error "File $1 does not exist"
fi

}


###################
# File encryption #
###################

encrypt() {

# encrypt file with password and AES256
# gpg
print_title "Symmetric encryption of \"$1\" with AES256 ..."
sleep 1

if [ "$(command -v gpg 2>/dev/null)" ]; then
  # check if file
  if [ -f "$1" ]; then
    if gpg -c --cipher-algo AES256 $1 2>/dev/null; then
      ENCRYPTOK="1"
      print_message "File \"$1\" encrypted to \"$1.gpg\""
      ENCRYPTEDFILE="$1.gpg"
    else
      ENCRYPTOK="" && print_error "File \"$1\" could not be encrypted"
    fi
    #remove original file
    # todo

  # check if directory
  elif [ -d "$1" ]; then
    print_message "Given file is a directory"
    tar_archive $1
    if gpg -c --cipher-algo AES256 $CREATEDARCHIVE 2>/dev/null; then
      ENCRYPTOK="1"
      echo && print_message "File \"$CREATEDARCHIVE\" encrypted to \"$CREATEDARCHIVE.gpg\""
      ENCRYPTEDFILE="$CREATEDARCHIVE.gpg"
    else
      ENCRYPTOK="" && print_error "File \"$CREATEDARCHIVE\" could not be encrypted"
    fi
  else
    print_error "File $1 does not exist"
  fi

else
  print_error "command \"gpg\" not found"
fi

}


#############
# Run parts #
#############

if [ ! "$SERVE" ]; then
  
  if [ "$ARCHIVE" ]; then tar_archive $DATA; fi
  if [ "$EXTRACT" ]; then tar_extract $DATATOEXTRACT; fi
  if [ "$ENCRYPT" ]; then encrypt $FILETOENCRYPT; fi
    
fi


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
    print_error "Aborting! No python nor php is installed."
  fi
fi


#####################
# Summarize Results #
#####################

print_title "Following parts where successful:"

if [ "$ARCHIVEOK" ]; then
  print_result "Archive $BYELLOW\"$CREATEDARCHIVE\"$NC created"
fi
if [ "$ENCRYPTOK" ]; then
  print_result "Given file encrypted to $BYELLOW\"$ENCRYPTEDFILE\"$NC"
fi

sleep 1
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



echo