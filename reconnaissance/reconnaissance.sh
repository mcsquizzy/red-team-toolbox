#!/bin/bash
# Reconnaissance


#############
# Functions #
#############

# Create banners
function fuBANNER {
  toilet -tf standard "$1"
}


####################################
# Check for command line arguments #
####################################

if [ "$1" == "" ];
  then
    echo "forgot the command line arguments!"
    exit
fi
for i in "$@"
  do
    case $i in
      --conf=*)
        myRECON_CONF_FILE="${i#*=}"
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
if [ "$myEXEC_TYPE" == "auto" ] && [ "$myRECON_CONF_FILE" == "" ];
  then
    echo "Aborting. No configuration file given. Additionally try --conf"
    exit
fi
if [ -s "$myRECON_CONF_FILE" ] && [ "$myRECON_CONF_FILE" != "" ];
  then
    myEXEC_TYPE="auto"
    if [ "$(head -n 1 $myRECON_CONF_FILE | grep -c "# reconnaissance")" == "1" ];
      then
        source "$myRECON_CONF_FILE"
      else
	    echo "Aborting. Config file \"$myRECON_CONF_FILE\" not a reconnaissance configuration file."
        exit
      fi
  elif ! [ -s "$myRECON_CONF_FILE" ] && [ "$myRECON_CONF_FILE" != "" ];
    then
      echo "Aborting. Config file \"$myRECON_CONF_FILE\" not found."
      exit
fi





######################################
# Gather Victim Identity Information #
######################################

fuBANNER "Gather Identity Information ..."
source ./identity-information.sh



#####################################
# Gather Victim Network Information #
#####################################




##################################
# Gather Victim Host Information #
##################################



