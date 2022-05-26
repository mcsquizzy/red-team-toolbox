######################
# Elevate Privileges #
######################

elevate_privileges() {

if [ ! "$QUIET" ]; then echo "
 _____ _                 _         ____       _       _ _                      
| ____| | _____   ____ _| |_ ___  |  _ \ _ __(_)_   _(_) | ___  __ _  ___  ___ 
|  _| | |/ _ \ \ / / _\` | __/ _ \ | |_) | '__| \ \ / / | |/ _ \/ _\` |/ _ \/ __|
| |___| |  __/\ V / (_| | ||  __/ |  __/| |  | |\ V /| | |  __/ (_| |  __/\__ \.
|_____|_|\___| \_/ \__,_|\__\___| |_|   |_|  |_| \_/ |_|_|\___|\__, |\___||___/
                                                                |___/           
"
fi

# check for root
if [ ! "$IAMROOT" ]; then fuERROR "Aborting! Not root. Try \"sudo sh $0\"" && echo && exit; fi

fuTITLE "Trying to add user \"$PRIVUSER\" to sudo group ..."
sleep 2
# check if given user exists
if id -u $PRIVUSER 1>/dev/null 2>&1; then
  fuMESSAGE "user $PRIVUSER found"
  if [ "$(command -v usermod 2>/dev/null)" ]; then
    # add user to sudo group
    if usermod -a -G sudo $PRIVUSER 2>/dev/null; then
      ELEVATEPRIVOK="1" && fuINFO "user \"$PRIVUSER\" added to sudo group"
    else
      ELEVATEPRIVOK="" && fuERROR "unable to add user \"$PRIVUSER\" to sudo group."
    fi
  else
    fuERROR "command \"usermod\" not found"
  fi
else
  fuERROR "user $PRIVUSER not found"
fi

}