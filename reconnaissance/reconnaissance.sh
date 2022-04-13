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

# Print banner
function fuBANNER {
  echo
  toilet -tf standard "$1" -F metal
  echo
}

# Print output title
function fuTITLE {
  echo
  echo -e "${BBLUE}════════════════════════════════════════════════════════════════════════"
  echo -e "${BGREEN} $1 ${BBLUE}"
  echo -e "════════════════════════════════════════════════════════════════════════${NC}"
}

# Print info line
function fuINFO {
  echo
  echo -e "${BBLUE}═══${BGREEN} $1 ${NC}"
}

# Print message line
function fuMESSAGE {
  echo -e "${BBLUE}---${NC} $1 ${NC}"
}

# Check for root permissions
function fuGOT_ROOT {
fuINFO "Checking for root"
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
  fuINFO "Upgrading packages"
  apt -y update
  fuINFO "Installing dependencies"
  apt -y install $DEPENDENCIES
}

function fuNmapSpoofingParameters {
  if [ "$NETDEVICE" != "" ] && [ "$SOURCEIP" != "" ] && [ "$SOURCEPORT" != "" ]; then
    echo -e$NETDEVICE -S$SOURCEIP -g$SOURCEPORT
  elif [ "$NETDEVICE" != "" ] && [ "$SOURCEIP" != "" ] && [ "$SOURCEPORT" == "" ]; then
    echo -e$NETDEVICE -S$SOURCEIP
  elif [ "$NETDEVICE" != "" ] && [ "$SOURCEIP" == "" ] && [ "$SOURCEPORT" != "" ]; then
    echo -e$NETDEVICE -g$SOURCEPORT
  elif [ "$NETDEVICE" != "" ] && [ "$SOURCEIP" == "" ] && [ "$SOURCEPORT" == "" ]; then
    echo -e$NETDEVICE
  elif [ "$NETDEVICE" == "" ] && [ "$SOURCEIP" != "" ] && [ "$SOURCEPORT" != "" ]; then
    echo -S$SOURCEIP -g$SOURCEPORT
  elif [ "$NETDEVICE" == "" ] && [ "$SOURCEIP" != "" ] && [ "$SOURCEPORT" == "" ]; then
    echo -S$SOURCEIP
  elif [ "$NETDEVICE" == "" ] && [ "$SOURCEIP" == "" ] && [ "$SOURCEPORT" != "" ]; then
    echo -g$SOURCEPORT
  else
    echo
  fi
}
SPOOFINGPARAMETERS=$(fuNmapSpoofingParameters)


####################################
# Check for command line arguments #
####################################

if [ "$1" == "" ]; then
  echo "forgot the command line arguments. Try --help"
  exit
fi
for i in "$@"
  do
    case $i in
      --conf=*)
        myCONF_FILE="${i#*=}"
        shift
      ;;
      --help)
        echo "Usage: $0 <options>"
        echo
        echo "--conf=<Path to \"reconnaissance.conf\">"
	      echo "  Use this to execute the reconnaissance phase."
        echo "  A configuration example is available in \"reconnaissance/reconnaissance.conf.dist\"."
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
if [ "$myCONF_FILE" == "" ]; then
  echo "Aborting. No configuration file given. Additionally try --conf"
  exit
fi
if [ -s "$myCONF_FILE" ] && [ "$myCONF_FILE" != "" ]; then
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

#####################
# Checking for root #
#####################

fuGOT_ROOT

################################
# Installation of Dependencies #
################################

fuGET_DEPS

############################
# Check configuration file #
############################

if [ "$IDENTITY" == true ] || [ "$NETWORK" == true ] || [ "$HOST" == true ] || [ "$VULN" == true ]; then
  fuTITLE "Following parts will be executed:"
  if [ "$IDENTITY" == true ]; then
    fuMESSAGE "Identity Scanning"
  fi
  if [ "$NETWORK" == true ]; then
    fuMESSAGE "Network Scanning"
  fi
  if [ "$HOST" == true ]; then
    fuMESSAGE "Host Scanning"
  fi
  if [ "$VULN" == true ]; then
    fuMESSAGE "Vulnerability Scanning"
  fi
else
  fuTITLE "No main variable in $myCONF_FILE set to true. Nothing to do."
  fuINFO "Specify your configuration in $myCONF_FILE and run script again."
  echo
  exit
fi

###############################
# Gather Identity Information #
###############################

if [ "$IDENTITY" == true ]; then
  fuBANNER "Gather Identity Information ..."
  source ./parts/identity-information.sh
fi

##############################
# Gather Network Information #
##############################

if [ "$NETWORK" == true ]; then
  fuBANNER "Gather Network Information ..."
  source ./parts/network-scanning.sh
fi

###########################
# Gather Host Information #
###########################

if [ "$HOST" == true ]; then
  fuBANNER "Gather Host Information ..."
  source ./parts/host-scanning.sh
fi

####################################
# Gather Vulnerability Information #
####################################

if [ "$VULN" == true ]; then
  fuBANNER "Gather Vulnerability Information ..."
  source ./parts/vulnerability-scanning.sh
fi

##############
# Next Steps #
##############

if [ "$IDENTITY" == true ] || [ "$NETWORK" == true ] || [ "$HOST" == true ] || [ "$VULN" == true ]; then

  fuBANNER "Next Steps To Do ..."

  if [ "$IP" == "" ]; then
    fuINFO "No specific IP set. Try set a specific ip address to gather more detailed information."
  fi

  if [ "$VULN" != true ]; then
    fuINFO "No vulnerability information gathered. Try set \"VULN\" variable to true and run script again."
    echo
  fi

  fuINFO "Search for possible vulnerabilities in directory \"output/\""

  fuINFO "Check the ../exploitation/README.md file on how to find exploits"  
  echo
fi