#!/bin/bash

# colors
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

# text
BOLD=$(tput bold)
NORMAL='\033[0;39m'



# testing:

echo
echo -e "$BPURPLE════════════════════════════════════════════════════════════════════════"
echo -e "$BYELLOW The fox jumps over the hedge $BPURPLE"
echo -e "════════════════════════════════════════════════════════════════════════$NC"

echo
echo -e "$BBLUE═══$BGREEN The fox jumps over the hedge $NC"

echo -e "$BBLUE---$YELLOW The fox jumps over the hedge $NC"