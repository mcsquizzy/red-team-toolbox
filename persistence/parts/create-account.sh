#################
# Local Account #
#################

add_user() {

if [ ! "$QUIET" ]; then echo "
    _       _     _   _                    _      _                             _   
   / \   __| | __| | | |    ___   ___ __ _| |    / \   ___ ___ ___  _   _ _ __ | |_ 
  / _ \ / _\` |/ _\` | | |   / _ \ / __/ _\` | |   / _ \ / __/ __/ _ \| | | | '_ \| __|
 / ___ \ (_| | (_| | | |__| (_) | (_| (_| | |  / ___ \ (_| (_| (_) | |_| | | | | |_ 
/_/   \_\__,_|\__,_| |_____\___/ \___\__,_|_| /_/   \_\___\___\___/ \__,_|_| |_|\__|
"
fi

# check for root
if [ ! "$IAMROOT" ]; then fuERROR "Aborting! Not root. Try \"sudo sh $0\"" && echo && exit; fi

# check -p parameter
if [ ! "$ADDPW" ]; then fuERROR "Aborting! No password given. You cannot login to that user until you set a password. Use the -p parameter" && echo && exit; fi

# check if /bin/bash exists
if [ -f "/bin/bash" ]; then BASH="1"; else BASH=""; fi

fuTITLE "Trying to add the user \"$USERNAME\" with root privileges ..."
sleep 2
if [ "$(command -v useradd 2>/dev/null)" ]; then
#if $USERADD -g 0 -M -d /root -s /bin/bash $USERNAME 2>/dev/null; then
  if [ "$BASH" ]; then
    if useradd -m -s /bin/bash $USERNAME 2>/dev/null; then
      ADDUSEROK="1" && fuINFO "user \"$USERNAME\" added"
    else
      ADDUSEROK="" && fuERROR "unable to add user \"$USERNAME\"."
    fi
  else
    if useradd -m -s /bin/sh $USERNAME 2>/dev/null; then
      ADDUSEROK="1" && fuINFO "user \"$USERNAME\" added"
    else
      ADDUSEROK="" && fuERROR "unable to add user \"$USERNAME\"."
    fi
  fi
else
  fuERROR "command \"useradd\" not found"
fi

# add user to sudo group
if [ "$ADDUSEROK" ]; then
  fuTITLE "Trying to add user \"$USERNAME\" to sudo group ..."
  sleep 2
  if [ "$(command -v usermod 2>/dev/null)" ]; then
    if usermod -a -G sudo $USERNAME 2>/dev/null; then
      fuINFO "user \"$USERNAME\" added to sudo group"
    else
      fuERROR "unable to add user \"$USERNAME\" to sudo group"
    fi
  else
    fuERROR "command \"usermod\" not found"
  fi
fi

# add password to given user
if id -u $USERNAME 2>/dev/null; then
  fuTITLE "Trying to add a password to user \"$USERNAME\" ..."
  sleep 2
  if [ "$ADDPW" ]; then
    if [ $(cat /etc/os-release | grep -i 'Name="ubuntu"') ]; then
      if echo "$USERNAME:$PW" | sudo chpasswd 1>/dev/null 2>&1; then
        fuINFO "given password added to user \"$USERNAME\""
      else
        fuERROR "unable to add the password to given user \"$USERNAME\""
      fi
    else
      if printf "$PW\n$PW" | sudo passwd $USERNAME 1>/dev/null 2>&1; then
        fuINFO "given password added to user \"$USERNAME\""
      else
        fuERROR "unable to add the password to given user \"$USERNAME\""
      fi
    fi
  fi
fi

}