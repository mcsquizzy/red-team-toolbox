#!/bin/bash
# Gather Identity Information

####################
# Global variables #
####################

DEPENDENCIES="sherlock spiderfoot"


################################
# Installation of Dependencies #
################################

if [ "$IAMROOT" ] && [ "$INET" ]; then
  fuGET_DEPS
else
  fuMESSAGE "Installation of dependencies skipped."
fi


###########################
# Create output directory #
###########################

if [ ! -d "output/" ]; then
  fuINFO "Creating \"./output/osint\" directory"
  mkdir output
  mkdir output/osint && echo "[ OK ]"
  echo
else
  fuINFO "Creating \"./output/osint\" directory"
  mkdir output/osint && echo "[ OK ]"
  echo
fi


###############
# Credentials #
###############

# Find Usernames across Social Network Websites
# sherlock
if [ "$USERNAME" != "" ]; then
  echo "Searching username $USERNAME on social network websites ..."
  sherlock --print-found --folderoutput ./output/osint/usernames/$USERNAME
fi

# Find Usernames from Human Name
# spiderfoot
if [ "$NAME" != "" ]; then
  echo "Searching for usernames from name $NAME ..."
  spiderfoot -s "$NAME" -t USERNAME -f -q | tee -a output/osint/usernames-of-${NAME}.txt
fi


###################
# Email Addresses #
###################

# Find email addresses of a domain
# spiderfoot
if [ "$DOMAIN" != "" ]; then
  echo "searching email addresses from domain $DOMAIN"
  spiderfoot -s $DOMAIN -t EMAILADDR -f -q | tee -a output/osint/emailaddresses.txt

elif [ "$EMAIL" != "" ]; then
  echo "searchin all types of information from email address $EMAIL"
  spiderfoot -s $EMAIL -q | tee -a output/osint/infos-from-$EMAIL.txt
fi

# Find email addresses from Human Name
# spiderfoot
if [ "$NAME" != "" ]; then
  echo "Searching for email addresses from name $NAME ..."
  spiderfoot -s "$NAME" -t EMAILADDR -f -q | tee -a output/osint/email-of-${NAME}.txt
fi

#theharvester
# check if needed


#####################
# Summarize results #
#####################

fuTITLE "Findings in following files:"

if [ -z "$(ls -A output/osint)" ]; then
  fuERROR "No OSINT / identity information found."
else
  fuRESULT "OSINT findings: ./output/osint/"
fi

echo