############
# SSH Keys #
############

if [ "$SSH" ]; then
  echo "
    __  __           _ _  __         ____ ____  _   _   _  __                      
   |  \/  | ___   __| (_)/ _|_   _  / ___/ ___|| | | | | |/ /___ _   _ ___         
   | |\/| |/ _ \ / _\` | | |_| | | | \___ \___ \| |_| | | ' // _ \ | | / __|        
   | |  | | (_) | (_| | |  _| |_| |  ___) |__) |  _  | | . \  __/ |_| \__ \  _ _ _ 
   |_|  |_|\___/ \__,_|_|_|  \__, | |____/____/|_| |_| |_|\_\___|\__, |___/ (_|_|_)
                             |___/                               |___/             
  "
  sleep 1

  # check if local ssh server is running
  fuTITLE "Check if local ssh server is running ..."
  sleep 2
  if ps aux | grep sshd | grep -v grep 2>/dev/null; then
    fuMESSAGE "Local ssh server is running"
  elif netstat -plant | grep :22 | grep LISTEN 2>/dev/null; then
    fuMESSAGE "Local ssh server is listening on port 22"
  else
    fuERROR "Probably no ssh server running on this host"
  fi

  # check if $HOME variable is set
  command -v whoami 2>/dev/null) || fuERROR "command \"whoami\" not found"
  $USER=$(whoami 2>/dev/null)
  if [ ! "$HOME" ]; then
    if [ -d "/home/$USER" ]; then
      HOME="/home/$USER"
    fi
  fi

  fuTITLE "Trying to add given SSH public key to authorized_keys file of user $USER ..."
  sleep 2
  if [ "$PUBKEY" != "" ]; then
    if [ -d "$HOME/.ssh" ]; then
      if echo "$PUBKEY" >> "$HOME"/.ssh/authorized_keys; then TRYCHMOD=""; else SSHOK="" && fuERROR "unable to write authorized_keys" && TRYCHMOD="1"; fi
      if [ "$TRYCHMOD" ]; then
        CHMOD=$(command -v chmod 2>/dev/null) || fuERROR "command \"chmod\" not found"
        $CHMOD 700 "$HOME"/.ssh 2>/dev/null
        echo "$PUBKEY" >> "$HOME"/.ssh/authorized_keys && SSHOK="1" && fuMESSAGE "authorized_keys updated"
      else
        SSHOK="1" && echo "authorized_keys updated"
      fi
    else
      fuINFO "No .ssh directory exists, creating one ..."
      MKDIR=$(command -v mkdir 2>/dev/null) || fuERROR "command \"mkdir\" not found"
      CHMOD=$(command -v chmod 2>/dev/null) || fuERROR "command \"chmod\" not found"
      $MKDIR "$HOME"/.ssh 2>/dev/null && $CHMOD 700 "$HOME"/.ssh 2>/dev/null
      if echo "$PUBKEY" >> "$HOME"/.ssh/authorized_keys; then SSHOK="1" && fuMESSAGE "authorized_keys updated"; else SSHOK="" && fuERROR "unable to write authorized_keys"; fi
    fi
  else
    fuERROR "No public key given."
  fi
fi