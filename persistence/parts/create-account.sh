#################
# Local Account #
#################

if [ "$ADDUSER" ]; then
  echo "
      _       _     _   _                    _      _                             _   
     / \   __| | __| | | |    ___   ___ __ _| |    / \   ___ ___ ___  _   _ _ __ | |_ 
    / _ \ / _\` |/ _\` | | |   / _ \ / __/ _\` | |   / _ \ / __/ __/ _ \| | | | \'_ \| __|
   / ___ \ (_| | (_| | | |__| (_) | (_| (_| | |  / ___ \ (_| (_| (_) | |_| | | | | |_ 
  /_/   \_\__,_|\__,_| |_____\___/ \___\__,_|_| /_/   \_\___\___\___/ \__,_|_| |_|\__|
  "
  sleep 1

  # without root
  #useradd -M -N -r -s /bin/bash #{username}

  # check if /bin/bash exists
  if [ -f "/bin/bash" ]; then BASH="1"; else BASH=""; fi

  # with root
  fuTITLE "Trying to add the user \"$USERNAME\" with root privileges ..."
  sleep 2

  USERADD=$(command -v useradd 2>/dev/null) || fuERROR "command \"useradd\" not found"
  USERMOD=$(command -v usermod 2>/dev/null) || fuERROR "command \"usermod\" not found"
  
  if [ "$BASH" ]; then
    if $USERADD -g 0 -M -d /root -s /bin/bash $USERNAME 2>/dev/null; then
      ADDUSEROK="1" && fuMESSAGE "user \"$USERNAME\" added"
    else
      ADDUSEROK="" && fuERROR "unable to add user \"$USERNAME\". You need root privileges. Try \"sudo sh $0\""
    fi
  else
    if $USERADD -g 0 -M -d /root -s /bin/sh $USERNAME 2>/dev/null; then
      ADDUSEROK="1" && fuMESSAGE "user \"$USERNAME\" added"
    else
      ADDUSEROK="" && fuERROR "unable to add user \"$USERNAME\". You need root privileges. Try \"sudo sh $0\""
    fi
  fi
  
  if [ "$ADDUSEROK" ]; then
    fuTITLE "Trying to add user \"$USERNAME\" to sudo group ..."
    sleep 1
    if $USERMOD -a -G sudo $USERNAME 2>/dev/null; then
      fuMESSAGE "user \"$USERNAME\" added to sudo group"
    else
      fuERROR "unable to add user \"$USERNAME\" to sudo group"
    fi

    fuTITLE "Trying to add a password to user \"$USERNAME\" ..."
    sleep 1
    if [ "$ADDPW" ]; then
      if [ $(cat /etc/os-release | grep -i 'Name="ubuntu"') ]; then
        echo "$USERNAME:$PW" | sudo chpasswd
      else
        echo "$PW" | passwd $USERNAME
      fi
    else
      fuERROR "No password given. You cannot login with that username until you create a password!!! Try \"sudo sh $0 -p\""
    fi
  fi

elif [ "$ADDPW" ]; then
  fuERROR "No username given. Try to add a user with -u parameter and combine it with -p"
fi