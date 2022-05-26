############
# SSH Keys #
############

modify_ssh_keys() {

if [ ! "$QUIET" ]; then echo "
   __  __           _ _  __         ____ ____  _   _   _  __                      
  |  \/  | ___   __| (_)/ _|_   _  / ___/ ___|| | | | | |/ /___ _   _ ___         
  | |\/| |/ _ \ / _\` | | |_| | | | \___ \___ \| |_| | | ' // _ \ | | / __|        
  | |  | | (_) | (_| | |  _| |_| |  ___) |__) |  _  | | . \  __/ |_| \__ \  
  |_|  |_|\___/ \__,_|_|_|  \__, | |____/____/|_| |_| |_|\_\___|\__, |___/ 
                            |___/                               |___/             
"
fi

# check for root
if [ "$IAMROOT" ]; then fuERROR "You are root! Don't run part \"modify ssh keys\" (-s) with \"sudo\"" && echo && exit; fi

# check if local ssh server is running
fuTITLE "Check if local ssh server is running ..."
sleep 2
if ps aux 1>/dev/null 2>&1 | grep sshd | grep -v grep; then
  fuMESSAGE "Local ssh server is running"
elif netstat -plant 1>/dev/null 2>&1 | grep :22 | grep LISTEN; then
  fuMESSAGE "Local ssh server is listening on port 22"
else
  fuERROR "Probably no ssh server running on this host"
fi

# set current user to $USER
if command -v whoami 1>/dev/null 2>&1; then
  USER=$(whoami 2>/dev/null)
else
  fuERROR "command \"whoami\" not found"
fi

# check if $HOME variable is set
if [ ! "$HOME" ]; then
  if [ -d "/home/$USER" ]; then
    HOME="/home/$USER"
  fi
fi

# get local ip addresses
LOCAL_IP=$(ip a | grep -vi docker | grep -Eo 'inet[^6]\S+[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{print $2}' | grep -E "^10\.|^172\.|^192\.168\.|^169\.254\.")

fuTITLE "Trying to add given ssh public key to authorized_keys file of user \"$USER\" ..."
sleep 2
if [ -d "$HOME/.ssh" ]; then
  if echo "$PUBKEY" >> "$HOME"/.ssh/authorized_keys; then TRYCHMOD=""; else SSHOK="" && fuERROR "unable to write authorized_keys" && TRYCHMOD="1"; fi
  if [ "$TRYCHMOD" ]; then
    if [ "$(command -v chmod 2>/dev/null)" ]; then
      chmod 700 "$HOME"/.ssh 2>/dev/null
      echo "$PUBKEY" >> "$HOME"/.ssh/authorized_keys && SSHOK="1" && fuINFO "authorized_keys updated"
    else 
      fuERROR "command \"chmod\" not found"
    fi
  else
    SSHOK="1" && echo "authorized_keys updated"
  fi
else
  fuINFO "No .ssh directory exists, creating one ..."
  if [ "$(command -v mkdir 2>/dev/null)" ]; then
    mkdir "$HOME"/.ssh 2>/dev/null && chmod 700 "$HOME"/.ssh 2>/dev/null && chmod 600 "$HOME"/.ssh/authorized_keys 2>/dev/null
  else
    fuERROR "command \"mkdir\" not found"
  fi
  if echo "$PUBKEY" >> "$HOME"/.ssh/authorized_keys; then SSHOK="1" && fuINFO "authorized_keys updated"; else SSHOK="" && fuERROR "unable to write authorized_keys"; fi
fi

}