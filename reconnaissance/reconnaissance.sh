#!/bin/bash
# Reconnaissance

####################
# Global variables #
####################

DEPENDENCIES="toilet"

# colors and text
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'

# bold
BRED='\033[1;31m'
BGREEN='\033[1;32m'
BYELLOW='\033[1;33m'
BBLUE='\033[1;34m'
BPURPLE='\033[1;35m'
BCYAN='\033[1;36m'

NC="\033[0m" # No Color
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

#############
# Functions #
#############

# Create banners
function fuBANNER {
  echo
  toilet -tf standard "$1" -F metal
  echo
}

# Create output title
function fuTITLE {
  echo
  echo -e "${BBLUE}══════════════════════════════════════════════════════"
  echo -e "${BGREEN} $1 ${BBLUE}"
  echo -e "══════════════════════════════════════════════════════${NC}"
}

# Create output messages
function fuMESSAGE {
  echo
  echo -e "${BBLUE}═══${BGREEN} $1 ${NC}"
}

# Check for root permissions
function fuGOT_ROOT {
echo
fuMESSAGE "Checking for root"
#echo -n "### Checking for root: "
if [ "$(whoami)" != "root" ]; then
  echo "[ NOT OK ]"
  echo "### Please run as root"
  echo "### Example: sudo $0"
  exit
else
  echo "[ OK ]"
fi
}

# Install dependencies
function fuGET_DEPS {
  fuMESSAGE "Upgrading packages"
  apt -y update
  fuMESSAGE "Installing dependencies"
  apt -y install $DEPENDENCIES
}


####################################
# Check for command line arguments #
####################################

if [ "$1" == "" ]; then
  echo "forgot the command line arguments!"
  exit
fi
for i in "$@"
  do
    case $i in
      --conf=*)
        myCONF_FILE="${i#*=}"
        shift
      ;;
      --type=manual)
        myEXEC_TYPE="${i#*=}"
        shift
      ;;
      --type=auto)
        myEXEC_TYPE="${i#*=}"
        shift
      ;;
      --help)
        echo "Usage: $0 <options>"
        echo
        echo "--conf=<Path to \"reconnaissance.conf\">"
	      echo "  Use this if you want to automatically execute the reconnaissance phase (--type=auto implied)."
        echo "  A configuration example is available in \"reconnaissance/recon.conf.dist\"."
        echo
        echo "--type=<[manual, auto]>"
	      echo "  manual, use this if you want to manually set the variables during the execution."
        echo "  auto, implied if a configuration file is passed as an argument for automatic execution."
        echo
	    exit
      ;;
      *)
	    exit
      ;;
    esac
  done

# Validate command line arguments and load config
# If a valid config file exists, set deployment type to "auto" and load the configuration
if [ "$myEXEC_TYPE" == "auto" ] && [ "$myCONF_FILE" == "" ]; then
  echo "Aborting. No configuration file given. Additionally try --conf"
  exit
fi
if [ -s "$myCONF_FILE" ] && [ "$myCONF_FILE" != "" ]; then
  myEXEC_TYPE="auto"
  if [ "$(head -n 1 $myCONF_FILE | grep -c "# reconnaissance")" == "1" ]; then
    source "$myCONF_FILE"
  else
	  echo "Aborting. Config file \"$myCONF_FILE\" not a reconnaissance configuration file."
    exit
fi
elif ! [ -s "$myCONF_FILE" ] && [ "$myCONF_FILE" != "" ]; then
  echo "Aborting. Config file \"$myCONF_FILE\" not found."
  exit
fi

################################
# Installation of Dependencies #
################################

fuGOT_ROOT
fuGET_DEPS


###############################
# Gather Identity Information #
###############################

if [ "$IDENTITY" == true ]; then
  fuBANNER "Gather Identity Information ..."
  source ./identity-information.sh
  fuMESSAGE "Finish message todo ..."
fi

##############################
# Gather Network Information #
##############################

if [ "$NETWORK" == true ]; then
  fuBANNER "Gather Network Information ..."
  source ./network-scanning.sh
fi


###########################
# Gather Host Information #
###########################

if [ "$HOST" == true ]; then
  fuBANNER "Gather Host Information ..."
  source ./host-scanning.sh
  fuMESSAGE "Finish message todo ..."
fi

####################################
# Gather Vulnerability Information #
####################################

if [ "$VULN" == true ]; then
  fuBANNER "Gather Vulnerability Information ..."
  source ./vulnerability-scanning.sh
  fuMESSAGE "Finish message todo ..."
fi
