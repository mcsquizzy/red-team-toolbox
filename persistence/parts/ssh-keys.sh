############
# SSH Keys #
############

# check if $HOME variable is set
USER=$(whoami 2>/dev/null || echo "User is unknown")
if [ ! "$HOME" ]; then
  if [ -d "/home/$USER" ];
    then HOME="/home/$USER";
  fi
fi

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

  # check if $HOME variable is set
  USER=$(whoami 2>/dev/null || echo "User is unknown")
  if [ ! "$HOME" ]; then
    if [ -d "/home/$USER" ];
        then HOME="/home/$USER";
    fi
  fi

  current_user=$(whoami 2>/dev/null)

  if [ "$PUBKEY" != "" ]; then
    fuTITLE "Trying to add given SSH public key to authorized_keys file of user $current_user ..."
    if [ -d "$HOME/.ssh" ]; then
      if echo "$PUBKEY" >> "$HOME"/.ssh/authorized_keys; then TRYCHMOD=""; else fuERROR "unable to write authorized_keys" && TRYCHMOD="1"; fi
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