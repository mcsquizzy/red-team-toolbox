#!/bin/sh
# Internal Reconnaissance

####################
# Global variables #
####################

# colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color
# bold
BRED="\033[1;31m"
BGREEN="\033[1;32m"
BYELLOW="\033[1;33m"
BBLUE="\033[1;34m"
# text
BOLD="$(tput bold)"
NORMAL="\033[0;39m"

# Get hostname
hostname=`hostname 2>/dev/null`

mySYSTEMFILE="${hostname}_system_info.txt"
myNETWFILE="${hostname}_network_info.txt"
myUSERFILE="${hostname}_user_info.txt"
myJOBSFILE="${hostname}_jobs_info.txt"
mySERVICESFILE="${hostname}_services_info.txt"
mySOFTWAREFILE="${hostname}_software_info.txt"
myINTERESTFILE="${hostname}_interesting_files.txt"
myCONTAINERFILE="${hostname}_container_info.txt"


#############
# Functions #
#############

# Print banner
print_banner() {
# http://patorjk.com/software/taag/#p=display&f=Graffiti&t=Type%20Something
echo "
  ___ _   _ _____ _____ ____  _   _    _    _       ____  _____ ____ ___  _   _ _   _    _    ___ ____ ____    _    _   _  ____ _____ 
 |_ _| \ | |_   _| ____|  _ \| \ | |  / \  | |     |  _ \| ____/ ___/ _ \| \ | | \ | |  / \  |_ _/ ___/ ___|  / \  | \ | |/ ___| ____|
  | ||  \| | | | |  _| | |_) |  \| | / _ \ | |     | |_) |  _|| |  | | | |  \| |  \| | / _ \  | |\___ \___ \ / _ \ |  \| | |   |  _|  
  | || |\  | | | | |___|  _ <| |\  |/ ___ \| |___  |  _ <| |__| |__| |_| | |\  | |\  |/ ___ \ | | ___) |__) / ___ \| |\  | |___| |___ 
 |___|_| \_| |_| |_____|_| \_\_| \_/_/   \_\_____| |_| \_\_____\____\___/|_| \_|_| \_/_/   \_\___|____/____/_/   \_\_| \_|\____|_____|
                                                                                                                                      
"
}

print_advisory() {
  echo
  echo "${BYELLOW}Advisory: ${BBLUE}Use this script for educational purposes and/or for authorized penetration testing only. The author is not responsible for any misuse or damage caused by this script. Use at your own risk.$NC"
  echo
}

# Print title
print_title() {
  echo
  for i in $(seq 80); do
    echo -n "$BBLUE═$NC"
  done
  echo
  echo "$BGREEN $1 $NC"
  for i in $(seq 80); do
    echo -n "$BBLUE═$NC"
  done
  echo
}

# Print info line
print_info() {
  echo
  echo "$BBLUE════$BGREEN $1 $NC"
}

# Print check line
print_check() {
  echo
  local title="$1"
  echo -n "$BBLUE════ $1 $NC"
  for i in $(seq $((${#title}+13)) 80); do
    echo -n "."
  done
}

print_ok() {
  echo -n " $BGREEN[yes]$NC"
  echo
}

print_notok() {
  echo -n "  $BRED[no]$NC"
  echo
}

# Print error line
print_error() {
  echo
  echo "$BBLUE════$BRED $1 $NC"
}

# Print results line
print_result() {
  echo
  echo "$BBLUE════$NC $1"
}

# Print next steps line
print_step() {
  echo
  echo "$BBLUE[X]$NC $1 $NC"
}

# Print message line
print_message() {
  echo "$BBLUE----$NC $1 $NC"
}

# Print attention message line
print_attention() {
  echo "$BLUE----$YELLOW $1 $NC"
}

# Check for root permissions
check_root() {
print_info "Checking for root"
if ([ -f /usr/bin/id ] && [ "$(/usr/bin/id -u)" -eq "0" ]) || [ "`whoami 2>/dev/null`" = "root" ]; then
  IAMROOT="1"
  print_message "You are root"
  echo
else
  IAMROOT=""
  print_message "You are not root"
  echo
fi
}


#####################################
# Check the command line parameters #
#####################################

PASSED_ARGS=$@
if [ "$PASSED_ARGS" != "" ]; then
  while getopts "h?cqw" opt; do
    case "$opt" in
      h|\?)
        echo
        echo "Usage: $0 [options]"
        echo
        echo "Options:"
        echo "-h    Show this help message"
        echo "-w    Serves a local web server for transferring files"
        echo
        echo "Output:"
        echo "-c    No colours. Without colours, the output can probably be read better"
        echo "-q    Quiet. No banner and no advisory displayed"
        echo
        exit;;
      c) NOCOLOUR="1";;
      w) SERVE="1";QUIET="1";;
      q) QUIET="1";;
      esac
  done
else
  echo "$0: no arguments passed to script. Try -h for help."
  echo
#  exit
fi

# validate OPTARG 
# todo

if [ "$NOCOLOUR" ]; then
  RED=""
  GREEN=""
  YELLOW=""
  BLUE=""
  NC=""
  BRED=""
  BGREEN=""
  BYELLOW=""
  BBLUE=""
fi


#########################################
# Banner, Advisory, Check for root, ... #
#########################################

if [ ! "$QUIET" ]; then 
  print_banner
  print_advisory
  check_root
fi
sleep 1


######################
# System Information #
######################

system_info() {

print_title "System information"
sleep 1

# current username
user=$(id -nu 2>/dev/null || whoami 2>/dev/null || echo $USER 2>/dev/null)
if [ "$user" ]; then
  echo "          $BYELLOW User:$NC $user"
else
  echo "          $BYELLOW User:$NC unknown"
fi

# user id
userid=$(id -u 2>/dev/null || echo $UID 2>/dev/null)
if [ "$userid" ]; then
  echo "       $BYELLOW User ID:$NC $userid"
else
  echo "       $BYELLOW User ID:$NC unknown"
fi

# home path
homepath=$(echo $HOME 2>/dev/null)
if [ "$homepath" ]; then
  echo "     $BYELLOW Home Path:$NC $homepath"
else
  echo "     $BYELLOW Home Path:$NC unknown"
fi

echo

# hostname
hostname=$(hostname 2>/dev/null)
if [ "$hostname" ]; then
  echo "      $BYELLOW Hostname:$NC $hostname"
else
  echo "      $BYELLOW Hostname:$NC unknown"
fi

# release version
kernelinfo=$(uname -r 2>/dev/null)
if [ "$kernelinfo" ]; then
  echo "$BYELLOW Kernel Release:$NC $kernelinfo"
else
  echo "$BYELLOW Kernel Release:$NC unknown"
fi

# distribution / version
versioninfo=$(cat /etc/*-release | grep PRETTY | cut -d "=" -f 2 | tr -d \" 2>/dev/null)
if [ "$versioninfo" ]; then
  echo "  $BYELLOW Distribution:$NC $versioninfo"
else
  echo "  $BYELLOW Distribution:$NC unknown"
fi

# architecture
architecture=$(uname -m 2>/dev/null)
if [ "$architecture" ]; then
  echo "  $BYELLOW Architecture:$NC $architecture"
else
  echo "  $BYELLOW Architecture:$NC unknown"
fi

sleep 1

# check if selinux is enabled
print_check "Check if SELinux is enabled"
sestatus=$(sestatus 2>/dev/null)
if [ "$sestatus" ]; then print_ok && echo "$sestatus"; else print_notok; fi

# list available shells
print_check "All available shells"
shells=$(cat /etc/shells 2>/dev/null)
if [ "$shells" ]; then print_ok && echo "$shells"; else print_notok; fi

# password policy
print_check "Password policy and password encryption method"
pwpolicy=$(grep "^PASS_MAX_DAYS\|^PASS_MIN_DAYS\|^PASS_WARN_AGE\|^LOGIN_RETRIES\|^ENCRYPT_METHOD" /etc/login.defs 2>/dev/null)
if [ "$pwpolicy" ]; then print_ok && echo "$pwpolicy"; else print_notok; fi

}

#######################
# Network Information #
#######################

network_info() {

print_title "Network information"
sleep 1

# current IP(s)
print_check "Current IP(s)"
currentip=$(ip a | grep -vi docker | grep -Eo 'inet[^6]\S+[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{print $2}' | grep -E "^10\.|^172\.|^192\.168\.|^169\.254\." 2>/dev/null)
currentif=$(ifconfig | grep -vi docker | grep -Eo 'inet[^6]\S+[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{print $2}' | grep -E "^10\.|^172\.|^192\.168\.|^169\.254\." 2>/dev/null)
if [ "$currentip" ]; then print_ok && echo "$currentip"; elif [ "$currentif" ]; then print_ok && echo "$currentif"; else print_notok; fi

# network interfaces / devices
print_check "Network interfaces / devices"
netdevices=$(cat /etc/networks 2>/dev/null ; (ip -br link || ifconfig -s || netstat -i) 2>/dev/null)
if [ "$netdevices" ]; then print_ok && echo "$netdevices"; else print_notok; fi

# dns info
print_check "DNS info"
dnsinfo=$(grep "nameserver" /etc/resolv.conf 2>/dev/null || systemd-resolve --status 2>/dev/null)
if [ "$dnsinfo" ]; then print_ok && echo "$dnsinfo"; else print_notok; fi

# route info
print_check "Route info"
defroute=$(route || ip r | grep default) 2>/dev/null
if [ "$defroute" ]; then print_ok && echo "$defroute"; else print_notok; fi

# open TCP connections
print_check "Listening TCP connections"
tcplisten=$(netstat -tlpn || ss -tln) 2>/dev/null
if [ "$tcplisten" ]; then print_ok && echo "$tcplisten"; else print_notok; fi

# open UDP connections
print_check "Listening UDP connections"
udplisten=$(netstat -ulpn || ss -uln) 2>/dev/null
if [ "$udplisten" ]; then print_ok && echo "$udplisten"; else print_notok; fi

}


####################
# User Information #
####################

user_info() {

print_title "User information"
sleep 1

# current user info
print_check "Current user info"
currentuser=$(id 2>/dev/null)
if [ "$currentuser" ]; then print_ok && echo "$currentuser"; else print_notok; fi

# check path variable of current user
print_check "Path config of current user"
pathconfig=$(echo $PATH 2>/dev/null)
if [ "$pathconfig" ]; then print_ok && echo "$pathconfig"; else print_notok; fi

# other users that have logged onto the system
print_check "Other users that have also logged onto the system"
lastloggedonusers=$(lastlog 2>/dev/null | grep -v Never)
if [ "$lastloggedonusers" ]; then print_ok && echo "$lastloggedonusers"; else print_notok; fi

# other users that are logged on right now
print_check "Are there users that are logged on right now?"
loggedonusers=$(w -h || who || users) 2>/dev/null
if [ "$loggedonusers" ]; then print_ok && echo "$loggedonusers"; else print_notok; fi

# users with a login shell
print_check "Are there users with a login shell?"
shellusers=$(grep -i "sh$" /etc/passwd 2>/dev/null | cut -d ":" -f1)
if [ "$shellusers" ]; then print_ok && echo "$shellusers"; else print_notok; fi

# all users
print_check "All users and the group they belong to"
allusers=$(cut -d ":" -f1 /etc/passwd 2>/dev/null | while read i; do id $i; done 2>/dev/null | sort)
if [ "$allusers" ]; then print_ok && echo "$allusers"; else print_notok; fi

# all users within a admin group
print_check "Are there users within a admin group? (admin, root, sudo, wheel)"
allusers=$(cut -d ":" -f1 /etc/passwd 2>/dev/null | while read i; do id $i; done 2>/dev/null | sort | grep -E "^adm|admin|root|sudo|wheel")
if [ "$allusers" ]; then print_ok && echo "$allusers"; else print_notok; fi

# user loggon history
print_check "Last logons"
lastlogons=$(last -Faiw | head -30 2>/dev/null || last | head -30 2>/dev/null)
if [ "$lastlogons" ]; then print_ok && echo "$lastlogons"; else print_notok; fi

# is /etc/shadow readable
print_check "Can we read /etc/shadow file?"
readshadow=$(cat /etc/shadow 2>/dev/null)
if [ "$readshadow" ]; then print_ok && echo "$readshadow"; else print_notok; fi

# hashes in /etc/passwd
print_check "Are there hashes in the /etc/passwd file?"
hashesinpasswd=$(grep -v '^[^:]*:[x]' /etc/passwd 2>/dev/null)
if [ "$hashesinpasswd" ]; then print_ok && echo "$hashesinpasswd"; else print_notok; fi

# is /etc/master.passwd readable
print_check "Can we read /etc/master.passwd file?"
readmaster=$(cat /etc/master.passwd 2>/dev/null)
if [ "$readmaster" ]; then print_ok && echo "$readmaster"; else print_notok; fi

# all root accounts (uid = 0)
print_check "Are there more root / superuser accounts?"
superuser=$(grep 'x:0:' /etc/passwd 2>/dev/null)
if [ "$superuser" ]; then print_ok && echo "$superuser"; else print_notok; fi

# home directory
print_check "Home directory permissions"
homedirperms=$(ls -lh /home/ 2>/dev/null)
if [ "$homedirperms" ]; then print_ok && echo "$homedirperms"; else print_notok; fi

# writable files
if ([ -f /usr/bin/id ] && [ "$(/usr/bin/id -u)" -ne "0" ]) || [ "`whoami 2>/dev/null`" != "root" ]; then
  print_check "Are there writable files but not owned by me?"
  writablefiles=$(find / -writable ! -user $(whoami) -type f ! -path "/proc/*" ! -path "/sys/*" -exec ls -al {} \; 2>/dev/null)
  if [ "$writablefiles" ]; then print_ok && echo "$writablefiles"; else print_notok; fi
fi

# is root allowed to login via SSH
print_check "Check if root is permitted to login via ssh"
rootssh=$(grep "PermitRootLogin " /etc/ssh/sshd_config 2>/dev/null | grep -v "#" | awk '{print  $2}')
if [ "$rootssh" = "yes" ]; then print_ok && (grep "PermitRootLogin " /etc/ssh/sshd_config 2>/dev/null | grep -v "#"); else print_notok; fi

####################
# Sudo Information #
####################

# sudoers config
print_check "Can we read Sudoers configuration?"
sudoers=$(grep -v -e '^$' /etc/sudoers | grep -v "#") 2>/dev/null
if [ "$sudoers" ]; then print_ok && echo "$sudoers"; else print_notok; fi

# sudo without password
print_check "Can we sudo without a password?"
sudopasswd=$(echo "" | sudo -S -l -k) 2>/dev/null
if [ "$sudopasswd" ]; then print_ok && echo "$sudopasswd"; else print_notok; fi

# past sudo uses
print_check "Check who have used sudo in the past"
whosudo=$(find /home -name .sudo_as_admin_successful 2>/dev/null)
if [ "$whosudo" ]; then print_ok && echo "$whosudo"; else print_notok; fi

}


############
# Cronjobs #
############

jobs_info() {

print_title "Information about (cron)jobs and tasks"
sleep 1

# list all cronjobs configured
print_check "Are there any cronjobs configured?"
cronjobs=$(ls -lh /etc/cron* 2>/dev/null)
if [ "$cronjobs" ]; then print_ok && echo "$cronjobs"; else print_notok; fi

# list all writable cronjobs
print_check "Are there any writeable cronjobs?"
cronwritable=$(find -L /etc/cron* /etc/anacron /var/spool/cron -writable 2>/dev/null)
if [ "$cronwritable" ]; then print_ok && echo "$cronwritable"; else print_notok; fi

# show content system-wide crontab
print_check "Can we read system-wide crontab /etc/crontab?"
crontab=$(cat /etc/crontab 2>/dev/null)
if [ "$crontab" ]; then print_ok && echo "$crontab"; else print_notok; fi

# /var/spool/cron/crontab/
print_check "Are there interesting files in /var/spool/cron/crontabs/?"
varspoolcrontab=$(ls -lha /var/spool/cron/crontabs 2>/dev/null)
if [ "$varspoolcrontab" ]; then print_ok && echo "$varspoolcrontab"; else print_notok; fi

# cronjobs of other users
print_check "Cronjobs of all users"
cronusers=$(cut -d ":" -f 1 /etc/passwd | xargs -n1 crontab -l -u 2>/dev/null | grep -v "#")
if [ "$cronusers" ]; then print_ok && echo "$cronusers"; else print_notok; fi

# anacron
# are there any anacron jobs
print_check "Anacron jobs?"
anacron=$(ls -la /etc/anacrontab 2>/dev/null)
if [ "$anacron" ]; then print_ok && echo "$anacron"; else print_notok; fi

# systemd timers
print_check "Systemd timers?"
systemdtimers=$(systemctl list-timers --all 2>/dev/null)
if [ "$systemdtimers" ]; then print_ok && echo "$systemdtimers"; else print_notok; fi

}


########################
# Processes / Services #
########################

services_info() {

print_title "Information about processes and services"
sleep 1

# all running processes
print_check "Running processes"
processes=$(ps aux 2>/dev/null)
if [ "$processes" ]; then print_ok && echo "$processes"; else print_notok; fi

# inetd / xinetd manages internet-based services (like ftp, telnet ...)
# is inetd or xinetd running
print_check "Check inetd / xinetd process"
xinetd=$(ps aux 2>/dev/null | egrep '[xi]netd' || netstat -tulpn 2>/dev/null | grep LISTEN | egrep '[xi]netd')
if [ "$xinetd" ]; then print_ok && echo "$xinetd"; else print_notok; fi

# check inetd config
print_check "Anything useful in inetd.conf?"
inetdconf=$(cat /etc/inetd.conf 2>/dev/null | grep -v "^#" | grep -ve "^$")
if [ "$inetdconf" ]; then print_ok && echo "$inetdconf"; else print_notok; fi

# check xinetd config
print_check "Anything useful in xinetd.conf?"
xinetdconf=$(cat /etc/xinetd.conf 2>/dev/null | grep -v "^#" | grep -ve "^$")
if [ "$xinetdconf" ]; then print_ok && echo "$xinetdconf"; else print_notok; fi

# init.d
print_check "List contents of /etc/init.d directory"
initd=$(ls -la /etc/init.d 2>/dev/null)
if [ "$initd" ]; then print_ok && echo "$initd"; else print_notok; fi

# init.d processes that not belong to root
print_check "Init.d files/services not belonging to root"
initdnotroot=$(find /etc/init.d/ \! -uid 0 -type f 2>/dev/null | xargs -r ls -la 2>/dev/null)
if [ "$initdnotroot" ]; then print_ok && echo "$initdnotroot"; else print_notok; fi

# check /etc/rc.d/init.d
print_check "Check /etc/rc.d/init.d"
rcd=$(ls -la /etc/rc.d/init.d 2>/dev/null)
if [ "$rcd" ]; then print_ok && echo "$rcd"; else print_notok; fi

# check /usr/local/etc/rc.d
print_check "Check /usr/local/etc/rc.d"
localrcd=$(ls -la /usr/local/etc/rc.d 2>/dev/null)
if [ "$localrcd" ]; then print_ok && echo "$localrcd"; else print_notok; fi

}


########################
# Software information #
########################

software_info() {

print_title "Information about installed software and possible versions"
sleep 1

# software packages
print_check "List installed software packages and versions"

# Arch Linux 
arch=$(pacman -Q 2>/dev/null)
if [ "$arch" ]; then print_ok && echo "$arch"; fi

# Alpine Linux
alpine=$(apk info -v 2>/dev/null)
if [ "$alpine" ]; then print_ok && echo "$alpine"; fi

# Debian / Ubuntu
debian=$(dpkg -l 2>/dev/null || apt list --installed 2>/dev/null)
if [ "$debian" ]; then print_ok && echo "$debian"; fi

# RHEL, Fedora, CentOS
rhel=$(yum list installed 2>/dev/null || dnf list installed 2>/dev/null)
if [ "$rhel" ]; then print_ok && echo "$rhel"; fi

# RPM
rpm=$(rpm -qa 2>/dev/null)
if [ "$rpm" ]; then print_ok && echo "$rpm"; fi

# openSUSE
opensuse=$(zypper se --installed-only 2>/dev/null)
if [ "$opensuse" ]; then print_ok && echo "$opensuse"; fi

# Snap
snap=$(snap list 2>/dev/null)
if [ "$snap" ]; then print_ok && echo "$snap"; fi

# Flatpak
flatpak=$(flatpak list --app 2>/dev/null)
if [ "$flatpak" ]; then print_ok && echo "$flatpak"; fi

}


#####################
# Interesting Files #
#####################

interesting_files() {

print_title "Interesting files"
sleep 1

# useful binaries
print_check "Useful tools / binaries for further investigation"
print_ok
command -v nc 2>/dev/null ; command -v netcat 2>/dev/null ; command -v wget 2>/dev/null ; command -v nmap 2>/dev/null ; command -v gcc 2>/dev/null; command -v curl 2>/dev/null

# suid, guid, sticky bit
# suid files
print_check "Files with SUID bit set"
suid=$(find / -perm -4000 -type f 2>/dev/null)
if [ "$suid" ]; then print_ok && echo "$suid"; else print_notok; fi

# guid files
print_check "Files with GUID bit set"
guid=$(find / -perm -2000 -type f 2>/dev/null)
if [ "$guid" ]; then print_ok && echo "$guid"; else print_notok; fi

# sticky bit files
print_check "Files with STICKY bit set"
sticky=$(find / -perm -1000 -type f 2>/dev/null)
if [ "$sticky" ]; then print_ok && echo "$sticky"; else print_notok; fi

# sticky bit directories
print_check "Directories with STICKY bit set"
stickyd=$(find / -perm -1000 -type d 2>/dev/null)
if [ "$stickyd" ]; then print_ok && echo "$stickyd"; else print_notok; fi


# history files
# user history
print_check "Current user's history files"
userhistory=$(ls -la $HOME/.*_history 2>/dev/null)
if [ "$userhistory" ]; then print_ok && echo "$userhistory"; else print_notok; fi

# roots history
print_check "Root's history files"
roothistory=$(ls -la /root/.*_history 2>/dev/null)
if [ "$roothistory" ]; then print_ok && echo "$roothistory"; else print_notok; fi

# bash history files
print_check "Other bash history files"
bashhistory=$(find /home -name .bash_history 2>/dev/null)
if [ "$bashhistory" ]; then print_ok && echo "$bashhistory"; else print_notok; fi


# private keys
print_check "Private keys"
privatekeys=$(grep -rl "PRIVATE KEY-----" /home 2>/dev/null)
if [ "$privatekeys" ]; then print_ok && echo "$privatekeys"; else print_notok; fi

# git files
print_check "Are there any Git credential files?"
gitfiles=$(find / -name ".git-credentials" 2>/dev/null)
if [ "$gitfiles" ]; then print_ok && echo "$gitfiles"; else print_notok; fi

# .plan files
print_check "Files with .plan extension"
planfiles=$(find / -iname *.plan -exec ls -la {} 2>/dev/null \;)
if [ "$planfiles" ]; then print_ok && echo "$planfiles"; else print_notok; fi

# bak files
print_check "Files with .bak extension"
bakfiles=$(find / -name *.bak -type f 2>/dev/null)
if [ "$bakfiles" ]; then print_ok && echo "$bakfiles"; else print_notok; fi

# mail
print_check "Accessible mail files"
mails=$(ls -la /var/mail 2>/dev/null)
if [ "$mails" ]; then print_ok && echo "$mails"; else print_notok; fi


# List Mozilla Firefox Bookmark Database Files on Linux
print_check "Are there firefox bookmarks?"
firefox=$(find / -path "*.mozilla/firefox/*/places.sqlite" 2>/dev/null)
if [ "$firefox" ]; then print_ok && echo "$firefox"; else print_notok; fi

}


####################
# Container Checks #
####################

container_info() {

print_title "Information about containers"
sleep 1

# Docker
# check if we are in a docker container
print_check "Check if we are in a docker container"
dockercontainer=$(grep -i docker /proc/self/cgroup 2>/dev/null || grep -i docker /proc/1/cgroup 2>/dev/null ; find / -iname "*dockerenv*" 2>/dev/null)
if [ "$dockercontainer" ]; then print_ok && echo "$dockercontainer"; else print_notok; fi

# check if we are a docker host
print_check "Check if we are a docker host"
dockerhost=$(docker --version 2>/dev/null ; docker ps -a 2>/dev/null)
if [ "$dockerhost" ]; then print_ok && echo "$dockerhost"; else print_notok; fi

# check if we are member of a docker group
print_check "Check if we are member of a docker group"
dockergroup=$(id | grep -i docker 2>/dev/null)
if [ "$dockergroup" ]; then print_ok && echo "$dockergroup"; else print_notok; fi

# look for any docker files
print_check "Check if there are any docker files"
dockerfiles=$(find / -iname *Dockerfile* 2>/dev/null ; find / -iname *docker-compose* 2>/dev/null)
if [ "$dockerfiles" ]; then print_ok && echo "$dockerfiles"; else print_notok; fi

# LXC Container
# check if we are in a lxc container
print_check "Check if we are in a lxc container"
lxccontainer=$(grep -qa container=lxc /proc/1/environ 2>/dev/null || grep -i lxc /proc/1/cgroup 2>/dev/null)
if [ "$lxccontainer" ]; then print_ok && echo "$lxccontainer"; else print_notok; fi

# check if we are member of a lxc/lxd group
print_check "Check if we are member of a lxc/lxd group"
lxcgroup=$(id | grep -i "lxc\|lxd" 2>/dev/null)
if [ "$lxcgroup" ]; then print_ok && echo "$lxcgroup"; else print_notok; fi

}


#############
# Run parts #
#############

run_all() {
system_info | tee $mySYSTEMFILE
network_info | tee $myNETWFILE
user_info | tee $myUSERFILE
jobs_info | tee $myJOBSFILE
services_info | tee $mySERVICESFILE
software_info | tee $mySOFTWAREFILE
interesting_files | tee $myINTERESTFILE
container_info | tee $myCONTAINERFILE
}

if [ ! "$SERVE" ]; then 
  run_all | tee ${hostname}_all_info.txt
  echo
  print_info "Internal Recon complete"
  echo
fi


##########################
# Serve local web server #
##########################

if [ "$SERVE" ]; then
  
  print_title "Serving a local web server on port 8000 ..."

  if command -v python3 1>/dev/null 2>&1; then
    python3 -m http.server 8000
  elif command -v python2 1>/dev/null 2>&1; then
    python2 -m SimpleHTTPServer 8000
  elif command -v php 1>/dev/null 2>&1; then
    php -S 0.0.0.0:8000
  else
    fuERROR "Aborting! No python nor php is installed."
  fi
fi


#####################
# Summarize Results #
#####################

print_title "Output in following files:"

if [ -s "$mySYSTEMFILE" ]; then
  print_result "System information written to: $BYELLOW$mySYSTEMFILE$NC"
fi
if [ -s "$myNETWFILE" ]; then
  print_result "Network information written to: $BYELLOW$myNETWFILE$NC"
fi
if [ -s "$myUSERFILE" ]; then
  print_result "User information written to: $BYELLOW$myUSERFILE$NC"
fi
if [ -s "$myJOBSFILE" ]; then
  print_result "Jobs / Tasks information written to: $BYELLOW$myJOBSFILE$NC"
fi
if [ -s "$mySERVICESFILE" ]; then
  print_result "Service / Process information written to: $BYELLOW$mySERVICESFILE$NC"
fi
if [ -s "$mySOFTWAREFILE" ]; then
  print_result "Software information written to: $BYELLOW$mySOFTWAREFILE$NC"
fi
if [ -s "$myINTERESTFILE" ]; then
  print_result "Information about interesting files written to: $BYELLOW$myINTERESTFILE$NC"
fi
if [ -s "$myCONTAINERFILE" ]; then
  print_result "Information about containers written to: $BYELLOW$myCONTAINERFILE$NC"
fi
if [ -s "${hostname}_all_info.txt" ]; then
  print_result "Report (all information together) written to: $BYELLOW${hostname}_all_info.txt$NC"
fi

echo


##############
# Next Steps #
##############
  
if [ ! "$QUIET" ]; then echo "
   _   _           _     ____  _                   _____       ____                
  | \ | | _____  _| |_  / ___|| |_ ___ _ __  ___  |_   _|__   |  _ \  ___          
  |  \| |/ _ \ \/ / __| \___ \| __/ _ \ '_ \/ __|   | |/ _ \  | | | |/ _ \         
  | |\  |  __/>  <| |_   ___) | ||  __/ |_) \__ \   | | (_) | | |_| | (_) |  _ _ _ 
  |_| \_|\___/_/\_\ __| |____/ \__\___| .__/|___/   |_|\___/  |____/ \___/  (_|_|_)
                                      |_|                                          
"
fi

print_step "Checkout the found information in one of the files created in the current directory."
print_step "Now, that you've got information about the current host/system, run lateral movement to gain information about systems around you."
# more to do

echo