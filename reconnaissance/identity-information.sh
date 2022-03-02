#!/bin/bash
# Gather Identity Information

####################
# Global variables #
####################

DEPENDENCIES="sherlock spiderfoot"

#############
# Functions #
#############

# Install dependencies
function fuGET_DEPS {
  echo
  echo "### Installing dependencies"
  echo
  apt -y install $DEPENDENCIES
}

################################
# Installation of Dependencies #
################################

fuGET_DEPS

##########################
# User interaction phase #
##########################

# Let's ask for user input if deployment type is manual
# In case of auto, variables are taken from config values

if [ "$myEXEC_TYPE" == "manual" ]; then
  read -ern 30 -p "Enter a Human Name: " myNAME
  read -ern 16 -p "Enter the Username: " myUSERNAME
  #echo -e "\nUsername : $myUSERNAME"
  read -ern 25 -p "Enter a Domain Name: " myDOMAIN
  read -ern 30 -p "Enter the Email Address: " myEMAIL
  #myUSERNAME=$(dialog --keep-window --title "[ Enter the username you wanted to search ]" --inputbox "\nUsername" 9 50 3>&1 1>&2 2>&3 3>&-)
  #dialog --keep-window --title "[ The username is ]" --yesno "\n$myUSERNAME" 7 50
  #myEMAIL=$(dialog --keep-window --title "[ Enter a email address you wanted to search ]" --inputbox "\nEmail" 9 50)
  #dialog --keep-window --title "[ The email address is ]" --yesno "\n$myEMAIL" 7 50
fi

#dialog --clear

###############
# Credentials #
###############

# Find Usernames across Social Network Websites
# sherlock
if [ "$myEXEC_TYPE" == "auto" ] && [ "$USERNAME" != "" ]; then
  echo "Searching username $USERNAME on social network websites ..."
  sherlock --print-found --folderoutput ./usernames/ $USERNAME

elif [ "$myEXEC_TYPE" == "manual" ] && [ "$myUSERNAME" != "" ]; then
  echo "Searching username $myUSERNAME on social network websites ..."
  sherlock --print-found --folderoutput ./usernames/ $myUSERNAME
fi

# Find Usernames from Human Name
# spiderfoot
if [ "$myEXEC_TYPE" == "auto" ] && [ "$NAME" != "" ]; then
  echo "Searching for usernames from name $NAME ..."
  spiderfoot -s "$NAME" -t USERNAME -f -q | tee -a usernames-of-${NAME}.txt

elif [ "$myEXEC_TYPE" == "manual" ] && [ "$myNAME" != "" ]; then
  echo "Searching for usernames from name "$myNAME" ..."
  spiderfoot -s "$myNAME" -t USERNAME -f -q | tee -a usernames-of-${myNAME}.txt
fi

###################
# Email Addresses #
###################

# Find email addresses of a domain
# spiderfoot
if [ "$myEXEC_TYPE" == "auto" ] && [ "$DOMAIN" != "" ]; then
  echo "searching email addresses from domain $DOMAIN"
  spiderfoot -s $DOMAIN -t EMAILADDR -f -q | tee -a emailaddresses.txt

elif [ "$myEXEC_TYPE" == "manual" ] && [ "$myDOMAIN" != "" ]; then
  echo "searching email addresses from domain $myDOMAIN"
  spiderfoot -s $myDOMAIN -t EMAILADDR -f -q | tee -a emailaddresses.txt

elif [ "$myEXEC_TYPE" == "auto" ] && [ "$EMAIL" != "" ]; then
  echo "searchin all types of information from email address $EMAIL"
  spiderfoot -s $EMAIL -q | tee -a infos-from-$EMAIL.txt

elif [ "$myEXEC_TYPE" == "manual" ] && [ "$myEMAIL" != "" ]; then
  echo "searchin all types of information from email address $myEMAIL"
  spiderfoot -s $myEMAIL -q | tee -a infos-from-$myEMAIL.txt
fi

# Find email addresses from Human Name
# spiderfoot
if [ "$myEXEC_TYPE" == "auto" ] && [ "$NAME" != "" ]; then
  echo "Searching for email addresses from name $NAME ..."
  spiderfoot -s "$NAME" -t EMAILADDR -f -q | tee -a email-of-${NAME}.txt

elif [ "$myEXEC_TYPE" == "manual" ] && [ "$myNAME" != "" ]; then
  echo "Searching for email addresses from name "${myNAME}" ..."
  spiderfoot -s "$myNAME" -t USERNAME -f -q | tee -a email-of-${myNAME}.txt
fi

#emailharvester

#theharvester



##################
# Employee Names #
##################
