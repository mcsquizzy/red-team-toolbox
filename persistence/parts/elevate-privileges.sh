######################
# Elevate Privileges #
######################

if [ "$ELEVATEPRIV" ]; then
  echo "
   _____ _                 _         ____       _       _ _                      
  | ____| | _____   ____ _| |_ ___  |  _ \ _ __(_)_   _(_) | ___  __ _  ___  ___ 
  |  _| | |/ _ \ \ / / _\` | __/ _ \ | |_) | '__| \ \ / / | |/ _ \/ _\` |/ _ \/ __|
  | |___| |  __/\ V / (_| | ||  __/ |  __/| |  | |\ V /| | |  __/ (_| |  __/\__ \.
  |_____|_|\___| \_/ \__,_|\__\___| |_|   |_|  |_| \_/ |_|_|\___|\__, |\___||___/
                                                                  |___/           
  "
 
  fuTITLE "Trying to add user \"$PRIVUSER\" to sudo group ..."
  sleep 2
  # check if given user exists
  if id -u $PRIVUSER >/dev/null 2>&1; then
    fuMESSAGE "user $PRIVUSER found"
    if USERMOD=$(command -v usermod 2>/dev/null); then
      # add user to sudo group
      if $USERMOD -a -G sudo $PRIVUSER 2>/dev/null; then
        ELEVATEPRIVOK="1" && fuINFO "user \"$PRIVUSER\" added to sudo group"
      else
        ELEVATEPRIVOK="" && fuERROR "unable to add user \"$PRIVUSER\" to sudo group. Try \"sudo sh $0 ...\""
      fi
    else
      fuERROR "command \"usermod\" not found"
    fi
  else
    fuERROR "user $PRIVUSER not found"
  fi
fi