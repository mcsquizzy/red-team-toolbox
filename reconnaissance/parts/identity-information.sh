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
  install_deps
else
  print_message "Installation of dependencies skipped."
fi


###########################
# Create output directory #
###########################

if [ ! -d "output/osint" ]; then
  print_info "Creating \"./output/osint\" directory"
  mkdir -p output/osint && echo "[ OK ]"
  echo
fi


###############
# Credentials #
###############

# Find Usernames across Social Network Websites
# sherlock
if [ "$USERNAME" != "" ]; then
  print_title "Searching username $USERNAME on social network websites ..."
  sherlock --print-found --folderoutput ./output/osint/usernames/$USERNAME
fi

# Find Usernames from Human Name
# spiderfoot
if [ "$NAME" != "" ]; then
  print_title "Searching for usernames from name $NAME ..."
  spiderfoot -s "$NAME" -t USERNAME -f -q | tee -a output/osint/usernames-of-${NAME}.txt
fi


###################
# Email Addresses #
###################

# Find email addresses of a domain
# spiderfoot
if [ "$DOMAIN" != "" ]; then
  print_title "searching email addresses from domain $DOMAIN"
  spiderfoot -s $DOMAIN -t EMAILADDR -f -q | tee -a output/osint/emailaddresses.txt

elif [ "$EMAIL" != "" ]; then
  print_title "searchin all types of information from email address $EMAIL"
  spiderfoot -s $EMAIL -q | tee -a output/osint/infos-from-$EMAIL.txt
fi

# Find email addresses from Human Name
# spiderfoot
if [ "$NAME" != "" ]; then
  print_title "Searching for email addresses from name $NAME ..."
  spiderfoot -s "$NAME" -t EMAILADDR -f -q | tee -a output/osint/email-of-${NAME}.txt
fi

#theharvester
# check if needed


#####################
# Summarize results #
#####################

print_title "Findings in following files:"

if [ -z "$(ls -A output/osint)" ]; then
  print_error "No OSINT / identity information found."
else
  print_result "OSINT findings: ./output/osint/"
fi

echo