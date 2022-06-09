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
  while getopts "h?a:u:e:d:rwcq" opt; do
    case "$opt" in
      h|\?)
        echo
        echo "Usage: $0 [options]"
        echo 
        echo "Options:"
        echo "-h                    Show this help message"
        echo "-a <file, directory>  Archive and compress given files or directory"
        echo "                      Specify directories without the last /"
        echo "-u <file.tar.gz>      Extract the given tar archive"
        echo "-e <file, directory>  Encrypt given file or directory (symmetric encryption with password)"
        echo "-d <file.gpg>         Decrypt given file"
        echo "-r                    Remove the original files"
        echo
        echo "-w                    Serves a local web server for transferring files"
        echo
        echo "Output:"
        echo "-c                    No colours. Without colours, the output can probably be read better"
        echo "-q                    Quiet. No banner and no advisory displayed"
        echo
        exit;;
      c) NOCOLOUR="1";;
      a) ARCHIVE="1";DATATOARCHIVE=$OPTARG;;
      u) EXTRACT="1";DATATOEXTRACT=$OPTARG;;
      e) ENCRYPT="1";DATATOENCRYPT=$OPTARG;;
      d) DECRYPT="1";FILETODECRYPT=$OPTARG;;
      r) REMOVE="1";;
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

# if no actions selected:
if [ ! "$ARCHIVE" ] && [ ! "$EXTRACT" ] && [ ! "$ENCRYPT" ] && [ ! "$DECRYPT" ] && [ ! "$SERVE" ]; then
  print_error "Aborting. No actions selected (-a, -u, -e, -d, -w), see -h."
  echo
  exit
fi

if [ "$DATATOEXTRACT" != "" ] && ! expr "$DATATOEXTRACT" : '^.*\.tar\.gz$' 1>/dev/null 2>&1; then
  print_error "Aborting. Given file not a tar archive (.tar.gz), see -h."
  echo
  exit
fi

if [ "$FILETODECRYPT" != "" ] && ! expr "$FILETODECRYPT" : '^.*\.gpg$' 1>/dev/null 2>&1; then
  print_error "Aborting. Given file not a gpg encrypted file (.gpg)."
  echo
  exit
fi

if [ "$REMOVE" ]; then
  echo
  print_attention "ATTENTION! You're about to remove files."
  echo
  while true; do
    read -p "Do you want to continue and probably remove files permanently? [y/n] " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
  done
  while true; do
    read -p "Are you sure? [y/n] " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
  done
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


##################
# Create archive #
##################

tar_archive() {

print_title "Create archive and compress \"$1\" ..."
sleep 1

# check if remove files after adding them to archive
if [ "$REMOVE" ]; then RF="--remove-files"; else RF=""; fi

if [ -f "$1" ] || [ -d "$1" ]; then
  if [ "$(command -v tar 2>/dev/null)" ]; then
    if tar czvf $1.tar.gz $1 $RF 1>/dev/null 2>&1; then
      ARCHIVEOK="1"
      CREATEDARCHIVE="$1.tar.gz"
      print_message "Archive $1.tar.gz created"
      print_message "Archive $1.tar.gz has following content:"
      tar tvf $1.tar.gz 2>/dev/null
      if [ "$REMOVE" ]; then echo && print_message "Data \"$*\" deleted"; fi
    else
      ARCHIVEOK="" && print_error "Archive not created. Check if \"$1\" exists."
    fi
  else
    print_error "command \"tar\" not found"
  fi
else
  # file or directory does not exist
  print_error "File or directory \"$1\" does not exist"
fi

}


######################
# Archive extraction #
######################

tar_extract() {

print_title "Extract and decompress archive \"$1\" ..."
sleep 1

if [ -f "$1" ]; then
  if [ "$(command -v tar 2>/dev/null)" ]; then
    if tar xzvf $1 2>/dev/null; then
      EXTRACTOK="1"
      print_message "Archive \"$1\" extracted"
    else
      EXTRACTOK="" && print_error "Archive $1 could not be extracted"
    fi
  else
    print_error "command \"tar\" not found"
  fi
else
  # file does not exist
  print_error "File \"$1\" does not exist"
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
  # check if its a file
  if [ -f "$1" ]; then
    if gpg -c --cipher-algo AES256 $1 2>/dev/null; then
      ENCRYPTOK="1"
      print_message "File \"$1\" encrypted to \"$1.gpg\""
      ENCRYPTEDFILE="$1.gpg"
    # in case of any errors but it sill worked
    elif [ -f "$1.gpg" ]; then
      ENCRYPTOK="1"
      print_message "File \"$1\" encrypted to \"$1.gpg\""
      ENCRYPTEDFILE="$1.gpg"
    else
      ENCRYPTOK="" && print_error "File \"$1\" could not be encrypted. Try with sudo."
    fi
    # remove original file
    if [ "$REMOVE" ] && [ "$ENCRYPTOK" ]; then
      if rm -f $1 1>/dev/null; then
        print_message "File \"$1\" deleted"
      fi
    fi

  # check if its a directory
  elif [ -d "$1" ]; then
    print_message "Given file is a directory"
    # create a tar archive from given directory
    tar_archive $1
    echo
    if gpg -c --cipher-algo AES256 $CREATEDARCHIVE 2>/dev/null; then
      ENCRYPTOK="1"
      echo && print_message "Directory \"$CREATEDARCHIVE\" encrypted to \"$CREATEDARCHIVE.gpg\""
      ENCRYPTEDFILE="$CREATEDARCHIVE.gpg"
    # in case of any errors but it sill worked
    elif [ -f "$CREATEDARCHIVE.gpg" ]; then
      ENCRYPTOK="1"
      echo && print_message "Directory \"$CREATEDARCHIVE\" encrypted to \"$CREATEDARCHIVE.gpg\""
      ENCRYPTEDFILE="$CREATEDARCHIVE.gpg"
    else
      ENCRYPTOK="" && print_error "Directory \"$CREATEDARCHIVE\" could not be encrypted. Try with sudo."
    fi
    # remove original directory
    if [ "$REMOVE" ] && [ "$ENCRYPTOK" ]; then
      if rm -rdf $CREATEDARCHIVE 1>/dev/null; then
        print_message "Directory \"$CREATEDARCHIVE\" deleted"
      fi
    fi

  else
    print_error "File or directory \"$1\" does not exist"
  fi

else
  print_error "command \"gpg\" not found"
fi

}


###################
# File decryption #
###################


decrypt() {

# decrypt with gpg
print_title "Decryption of \"$1\" ..."
sleep 1

if [ -f "$1" ]; then
  if [ "$(command -v gpg 2>/dev/null)" ]; then
    if gpg $1 2>/dev/null; then
      DECRYPTOK="1"
      echo && print_message "File \"$1\" decrypted"
    # error messages because of permissions
    elif ! ([ -f /usr/bin/id ] && [ "$(/usr/bin/id -u)" -eq "0" ]) || [ "`whoami 2>/dev/null`" = "root" ]; then
      DECRYPTOK="1"
      echo && print_message "File \"$1\" decrypted"
    else
      DECRYPTOK="" && print_error "File $1 could not be decrypted."
    fi
  else
    print_error "command \"gpg\" not found"
  fi
else
  # file does not exist
  print_error "File \"$1\" does not exist"
fi

}


#############
# Run parts #
#############

if [ ! "$SERVE" ]; then
  
  if [ "$ARCHIVE" ]; then tar_archive $DATATOARCHIVE; fi
  if [ "$EXTRACT" ]; then tar_extract $DATATOEXTRACT; fi
  if [ "$ENCRYPT" ]; then encrypt $DATATOENCRYPT; fi
  if [ "$DECRYPT" ]; then decrypt $FILETODECRYPT; fi

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
  print_result "Creation of archive $BYELLOW\"$CREATEDARCHIVE\"$NC"
fi
if [ "$EXTRACTOK" ]; then
  print_result "Extraction of archive $BYELLOW\"$DATATOEXTRACT\"$NC"
fi
if [ "$ENCRYPTOK" ]; then
  print_result "File encryption to $BYELLOW\"$ENCRYPTEDFILE\"$NC"
fi
if [ "$DECRYPTOK" ]; then
  print_result "Decryption of file \"$FILETODECRYPT\"$NC"
fi

sleep 2
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

print_step "If you want to encrypt and remove files, search for backup files on this system. Use \"internal-recon.sh\" script from this toolbox." 

if [ "$REMOVE" ]; then
  print_step "Note that after you deleted files with \"rm\", it might be possible to recover some of its contents (see \"rm --help\"). You may consider using \"shred\" to overwrite files (see \"shred --help\")."
fi

echo