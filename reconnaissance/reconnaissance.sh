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
  echo -e "${BBLUE}═════════════════════════════════════════════════════════════════════"
  echo -e "${BGREEN} $1 ${BBLUE}"
  echo -e "═════════════════════════════════════════════════════════════════════${NC}"
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
        echo "  A configuration example is available in \"reconnaissance/reconnaissance.conf.dist\"."
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

#####################
# Checking for root #
#####################

fuGOT_ROOT

################################
# Installation of Dependencies #
################################

fuGET_DEPS

###############################
# Gather Identity Information #
###############################

if [ "$IDENTITY" == true ]; then
  fuBANNER "Gather Identity Information ..."
  source ./identity-information.sh
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
fi

####################################
# Gather Vulnerability Information #
####################################

if [ "$VULN" == true ]; then
  fuBANNER "Gather Vulnerability Information ..."
  source ./vulnerability-scanning.sh
fi

###############
# Next Steps  #
###############

# Checking config file
if [ "$IDENTITY" != true ] && [ "$NETWORK" != true ] && [ "$HOST" != true ] && [ "$VULN" != true ]; then
  fuINFO "No main variable in $myCONF_FILE set to true. No information is gathered"
  fuINFO "Specify your configuration in $myCONF_FILE and run script again."

else
  fuBANNER "Next steps to do ..."

  fuMESSAGE "Search for possible vulnerabilities in directory \"output/\""

  fuMESSAGE "Try \"searchsploit\" to search for an exploit by keywords"
  fuMESSAGE "Example: Keyword openssh: \"$ searchsploit openssh -www\""
  fuMESSAGE "Try \"metasploit (msfconsole)\" to search for an exploit by a given CVE Number or EDB-ID"
  fuMESSAGE "Example: CVE: 2010-2075: \"$ msfconsole -x \"search cve:2010-2075; exit;\" -q"
  #fuMESSAGE "Search a CVE number and set it in the exploitation.conf file. The script will search for exploits to the given CVE"


  if [ -s "$myVULNFILE" ]; then
    fuMESSAGE "Search a vulnerability found in $myVULNFILE."
  fi

fi