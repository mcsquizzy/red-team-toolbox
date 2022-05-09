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
fuBANNER() {
# http://patorjk.com/software/taag/#p=display&f=Graffiti&t=Type%20Something
echo "
  ___ _   _ _____ _____ ____  _   _    _    _       ____  _____ ____ ___  _   _ _   _    _    ___ ____ ____    _    _   _  ____ _____ 
 |_ _| \ | |_   _| ____|  _ \| \ | |  / \  | |     |  _ \| ____/ ___/ _ \| \ | | \ | |  / \  |_ _/ ___/ ___|  / \  | \ | |/ ___| ____|
  | ||  \| | | | |  _| | |_) |  \| | / _ \ | |     | |_) |  _|| |  | | | |  \| |  \| | / _ \  | |\___ \___ \ / _ \ |  \| | |   |  _|  
  | || |\  | | | | |___|  _ <| |\  |/ ___ \| |___  |  _ <| |__| |__| |_| | |\  | |\  |/ ___ \ | | ___) |__) / ___ \| |\  | |___| |___ 
 |___|_| \_| |_| |_____|_| \_\_| \_/_/   \_\_____| |_| \_\_____\____\___/|_| \_|_| \_/_/   \_\___|____/____/_/   \_\_| \_|\____|_____|
                                                                                                                                      
"
}

# Print output title
fuTITLE() {
  echo
  echo "$BBLUE════════════════════════════════════════════════════════════════════════════"
  echo "$BGREEN $1 $BBLUE"
  echo "════════════════════════════════════════════════════════════════════════════$NC"
}

# Print info line
fuINFO() {
  echo
  echo "$BBLUE════$BGREEN $1 $NC"
}

# Print info line
fuCHECKS() {
  echo
  printf "$BBLUE════$BYELLOW $1 $NC"
}

fuOK() {
  echo "$BGREEN[OK]$NC"
}

fuNOTOK() {
  echo "$BRED[Failed]$NC"
}

# Print error line
fuERROR() {
  echo
  echo "$BBLUE════$BRED $1 $NC"
}

# Print results line
fuRESULT() {
  echo
  echo "$BBLUE════$NC $1"
}

# Print next steps line
fuSTEPS() {
  echo
  echo "$BBLUE[X]$NC $1 $NC"
}

# Print message line
fuMESSAGE() {
  echo "$BBLUE----$NC $1 $NC"
}

# Print attention message line
fuATTENTION() {
  echo "$BLUE----$YELLOW $1 $NC"
}

# Check for root permissions
fuGOT_ROOT() {
fuINFO "Checking for root"
if ([ -f /usr/bin/id ] && [ "$(/usr/bin/id -u)" -eq "0" ]) || [ "`whoami 2>/dev/null`" = "root" ]; then
  IAMROOT="1"
  fuMESSAGE "You are root"
  echo
else
  IAMROOT=""
  fuMESSAGE "You are not root"
  echo
fi
}


#####################################
# Check the command line parameters #
#####################################

PASSED_ARGS=$@
if [ "$PASSED_ARGS" != "" ]; then
  while getopts "h?c" opt; do
    case "$opt" in
      h|\?)
        echo
        echo "Usage: sh $0 [-h/-?] [-c]"
        echo
        echo "-h/-?"
        echo "  Show this help message"
        echo
        echo "-c"
        echo "  No colours"
        echo "  Without colours, the output can probably be read better"
        echo
        exit;;
      c) NOCOLOUR="1";;
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

##########
# Banner #
##########

fuBANNER
echo
echo "${BYELLOW}Advisory: ${BBLUE}Use this script for educational purposes and/or for authorized penetration testing only. The author is not responsible for any misuse or damage caused by this script. Use at your own risk.$NC"
echo
sleep 1

#####################
# Checking for root #
#####################

fuGOT_ROOT
sleep 1

######################
# System Information #
######################

system_info() {

fuTITLE "System information"
sleep 1

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

# check if selinux is enabled
fuCHECKS "Check if SELinux is enabled"
sestatus=$(sestatus 2>/dev/null)
if [ "$sestatus" ]; then fuOK && echo "$sestatus"; else fuNOTOK; fi

# list available shells
fuCHECKS "All available shells"
shells=$(cat /etc/shells 2>/dev/null)
if [ "$shells" ]; then fuOK && echo "$shells"; else fuNOTOK; fi

# password policy
fuCHECKS "Password policy and password encryption method"
pwpolicy=$(grep "^PASS_MAX_DAYS\|^PASS_MIN_DAYS\|^PASS_WARN_AGE\|^LOGIN_RETRIES\|^ENCRYPT_METHOD" /etc/login.defs 2>/dev/null)
if [ "$pwpolicy" ]; then fuOK && echo "$pwpolicy"; else fuNOTOK; fi

}

#######################
# Network Information #
#######################

network_info() {

fuTITLE "Network information"
sleep 1

# current IP(s)
fuCHECKS "Current IP"
currentip=$(ip a | grep -vi docker | grep -Eo 'inet[^6]\S+[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{print $2}' | grep -E "^10\.|^172\.|^192\.168\.|^169\.254\." 2>/dev/null)
currentif=$(ifconfig | grep -vi docker | grep -Eo 'inet[^6]\S+[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{print $2}' | grep -E "^10\.|^172\.|^192\.168\.|^169\.254\." 2>/dev/null)
if [ "$currentip" ]; then fuOK && echo "$currentip"; elif [ "$currentif" ]; then fuOK && echo "$currentif"; else fuNOTOK; fi

# dns info
fuCHECKS "DNS info"
dnsinfo=$(grep "nameserver" /etc/resolv.conf 2>/dev/null || systemd-resolve --status 2>/dev/null)
if [ "$dnsinfo" ]; then fuOK && echo "$dnsinfo"; else fuNOTOK; fi

# route info
fuCHECKS "Route info"
defroute=$(route || ip r | grep default) 2>/dev/null
if [ "$defroute" ]; then fuOK && echo "$defroute"; else fuNOTOK; fi

# open TCP connections
fuCHECKS "Listening TCP connections"
tcplisten=$(netstat -tlpn || ss -tln) 2>/dev/null
if [ "$tcplisten" ]; then fuOK && echo "$tcplisten"; else fuNOTOK; fi

# open UDP connections
fuCHECKS "Listening UDP connections"
udplisten=$(netstat -ulpn || ss -uln) 2>/dev/null
if [ "$udplisten" ]; then fuOK && echo "$udplisten"; else fuNOTOK; fi
}


####################
# User Information #
####################

user_info() {

fuTITLE "User information"
sleep 1

# current user info
fuCHECKS "Current user info"
currentuser=$(id 2>/dev/null)
if [ "$currentuser" ]; then fuOK && echo "$currentuser"; else fuNOTOK; fi

# check path variable of current user
fuCHECKS "Path config of current user"
pathconfig=$(echo $PATH 2>/dev/null)
if [ "$pathconfig" ]; then fuOK && echo "$pathconfig"; else fuNOTOK; fi

# other users that have logged onto the system
fuCHECKS "Users that have also logged onto the system"
lastloggedonusers=$(lastlog 2>/dev/null | grep -v Never)
if [ "$lastloggedonusers" ]; then fuOK && echo "$lastloggedonusers"; else fuNOTOK; fi

# other users that are logged on right now
fuCHECKS "Users that are logged on right now"
loggedonusers=$(w -h || who || users) 2>/dev/null
if [ "$loggedonusers" ]; then fuOK && echo "$loggedonusers"; else fuNOTOK; fi

# users with a login shell
fuCHECKS "All users with a login shell"
shellusers=$(cat /etc/passwd 2>/dev/null | grep -i "sh$" | cut -d ":" -f 1)
if [ "$shellusers" ]; then fuOK && echo "$shellusers"; else fuNOTOK; fi

# all users
fuCHECKS "All users and the group they belong to"
allusers=$(cut -d ":" -f1 /etc/passwd 2>/dev/null | while read i; do id $i; done 2>/dev/null | sort)
if [ "$allusers" ]; then fuOK && echo "$allusers"; else fuNOTOK; fi

# all users within a admin group
fuCHECKS "All users within a admin group (admin, root, sudo, wheel)"
allusers=$(cut -d ":" -f1 /etc/passwd 2>/dev/null | while read i; do id $i; done 2>/dev/null | sort | grep -E "^adm|admin|root|sudo|wheel")
if [ "$allusers" ]; then fuOK && echo "$allusers"; else fuNOTOK; fi

# user loggon history
fuCHECKS "Last logons"
lastlogons=$(last -Faiw | head -30 2>/dev/null || last | head -30 2>/dev/null)
if [ "$lastlogons" ]; then fuOK && echo "$lastlogons"; else fuNOTOK; fi

# is /etc/shadow readable
fuCHECKS "Can we read /etc/shadow file?"
readshadow=$(cat /etc/shadow 2>/dev/null)
if [ "$readshadow" ]; then fuOK && echo "$readshadow"; else fuNOTOK; fi

# hashes in /etc/passwd
fuCHECKS "Are there hashes in the /etc/passwd file?"
hashesinpasswd=$(grep -v '^[^:]*:[x]' /etc/passwd 2>/dev/null)
if [ "$hashesinpasswd" ]; then fuOK && echo "$hashesinpasswd"; else fuNOTOK; fi

# is /etc/master.passwd readable
fuCHECKS "Can we read /etc/master.passwd file?"
readmaster=$(cat /etc/master.passwd 2>/dev/null)
if [ "$readmaster" ]; then fuOK && echo "$readmaster"; else fuNOTOK; fi

# all root accounts (uid = 0)
fuCHECKS "All root / superuser accounts"
superuser=$(grep 'x:0:' /etc/passwd 2>/dev/null)
if [ "$superuser" ]; then fuOK && echo "$superuser"; else fuNOTOK; fi

# home directory
fuCHECKS "Home directory permissions"
homedirperms=$(ls -lh /home/ 2>/dev/null)
if [ "$homedirperms" ]; then fuOK && echo "$homedirperms"; else fuNOTOK; fi

# writable files
if ([ -f /usr/bin/id ] && [ "$(/usr/bin/id -u)" -ne "0" ]) || [ "`whoami 2>/dev/null`" != "root" ]; then
  fuCHECKS "Writable files but not owned by me"
  writablefiles=$(find / -writable ! -user $(whoami) -type f ! -path "/proc/*" ! -path "/sys/*" -exec ls -al {} \; 2>/dev/null)
  if [ "$writablefiles" ]; then fuOK && echo "$writablefiles"; else fuNOTOK; fi
fi

# is root allowed to login via SSH
fuCHECKS "Check if root is permitted to login via ssh"
rootssh=$(grep "PermitRootLogin " /etc/ssh/sshd_config 2>/dev/null | grep -v "#" | awk '{print  $2}')
if [ "$rootssh" = "yes" ]; then fuOK && (grep "PermitRootLogin " /etc/ssh/sshd_config 2>/dev/null | grep -v "#"); else fuNOTOK; fi

####################
# Sudo Information #
####################

# sudoers config
fuCHECKS "Sudoers configuration"
sudoers=$(grep -v -e '^$' /etc/sudoers | grep -v "#") 2>/dev/null
if [ "$sudoers" ]; then fuOK && echo "$sudoers"; else fuNOTOK; fi

# sudo without password
fuCHECKS "Sudo without a password"
sudopasswd=$(echo "" | sudo -S -l -k) 2>/dev/null
if [ "$sudopasswd" ]; then fuOK && echo "$sudopasswd"; else fuNOTOK; fi

# past sudo uses
fuCHECKS "Check who have used sudo in the past"
whosudo=$(find /home -name .sudo_as_admin_successful 2>/dev/null)
if [ "$whosudo" ]; then fuOK && echo "$whosudo"; else fuNOTOK; fi

}


############
# Cronjobs #
############

jobs_info() {

fuTITLE "Information about (cron)jobs and tasks"
sleep 1

# list all cronjobs configured
fuCHECKS "Check if there are any cronjobs configured"
cronjobs=$(ls -lh /etc/cron* 2>/dev/null)
if [ "$cronjobs" ]; then fuOK && echo "$cronjobs"; else fuNOTOK; fi

# list all writable cronjobs
fuCHECKS "Check if there are any writeable cronjobs"
cronwritable=$(find -L /etc/cron* /etc/anacron /var/spool/cron -writable 2>/dev/null)
if [ "$cronwritable" ]; then fuOK && echo "$cronwritable"; else fuNOTOK; fi

# show content system-wide crontab
fuCHECKS "Content of system-wide crontab /etc/crontab"
crontab=$(cat /etc/crontab 2>/dev/null)
if [ "$crontab" ]; then fuOK && echo "$crontab"; else fuNOTOK; fi

# /var/spool/cron/crontab/
fuCHECKS "Interesting files in /var/spool/cron/crontabs/"
varspoolcrontab=$(ls -lha /var/spool/cron/crontabs 2>/dev/null)
if [ "$varspoolcrontab" ]; then fuOK && echo "$varspoolcrontab"; else fuNOTOK; fi

# cronjobs of other users
fuCHECKS "Cronjobs of all users"
cronusers=$(cut -d ":" -f 1 /etc/passwd | xargs -n1 crontab -l -u 2>/dev/null | grep -v "#")
if [ "$cronusers" ]; then fuOK && echo "$cronusers"; else fuNOTOK; fi

# anacron
# are there any anacron jobs
fuCHECKS "Anacron jobs"
anacron=$(ls -la /etc/anacrontab 2>/dev/null)
if [ "$anacron" ]; then fuOK && echo "$anacron"; else fuNOTOK; fi

# systemd timers
fuCHECKS "Systemd timers"
systemdtimers=$(systemctl list-timers --all 2>/dev/null)
if [ "$systemdtimers" ]; then fuOK && echo "$systemdtimers"; else fuNOTOK; fi

}


########################
# Processes / Services #
########################

services_info() {

fuTITLE "Information about processes and services"
sleep 1

# all running processes
fuCHECKS "Running processes"
processes=$(ps aux 2>/dev/null)
if [ "$processes" ]; then fuOK && echo "$processes"; else fuNOTOK; fi

# inetd / xinetd manages internet-based services (like ftp, telnet ...)
# is inetd or xinetd running
fuCHECKS "Check inetd / xinetd process"
xinetd=$(ps aux 2>/dev/null | egrep '[xi]netd' || netstat -tulpn 2>/dev/null | grep LISTEN | egrep '[xi]netd')
if [ "$xinetd" ]; then fuOK && echo "$xinetd"; else fuNOTOK; fi

# check inetd config
fuCHECKS "Anything useful in inetd.conf"
inetdconf=$(cat /etc/inetd.conf 2>/dev/null | grep -v "#" | grep -ve "^$")
if [ "$inetdconf" ]; then fuOK && echo "$inetdconf"; else fuNOTOK; fi

# check xinetd config
fuCHECKS "Anything useful in xinetd.conf"
xinetdconf=$(cat /etc/xinetd.conf 2>/dev/null | grep -v "#" | grep -ve "^$")
if [ "$xinetdconf" ]; then fuOK && echo "$xinetdconf"; else fuNOTOK; fi

# init.d
fuCHECKS "List contents of /etc/init.d directory"
initd=$(ls -la /etc/init.d 2>/dev/null)
if [ "$initd" ]; then fuOK && echo "$initd"; else fuNOTOK; fi

# init.d processes that not belong to root
fuCHECKS "Init.d files/services not belonging to root"
initdnotroot=$(find /etc/init.d/ \! -uid 0 -type f 2>/dev/null | xargs -r ls -la 2>/dev/null)
if [ "$initdnotroot" ]; then fuOK && echo "$initdnotroot"; else fuNOTOK; fi

# check /etc/rc.d/init.d
fuCHECKS "Check /etc/rc.d/init.d"
rcd=$(ls -la /etc/rc.d/init.d 2>/dev/null)
if [ "$rcd" ]; then fuOK && echo "$rcd"; else fuNOTOK; fi

# check /usr/local/etc/rc.d
fuCHECKS "Check /usr/local/etc/rc.d"
localrcd=$(ls -la /usr/local/etc/rc.d 2>/dev/null)
if [ "$localrcd" ]; then fuOK && echo "$localrcd"; else fuNOTOK; fi

}


########################
# Software information #
########################

software_info() {

fuTITLE "Information about installed software and possible versions"
sleep 1

# software packages
fuCHECKS "List installed software packages and versions"

# Arch Linux 
arch=$(pacman -Q 2>/dev/null)
if [ "$arch" ]; then fuOK && echo "$arch"; fi

# Alpine Linux
alpine=$(apk info -v 2>/dev/null)
if [ "$alpine" ]; then fuOK && echo "$alpine"; fi

# Debian / Ubuntu
debian=$(dpkg -l 2>/dev/null || apt list --installed 2>/dev/null)
if [ "$debian" ]; then fuOK && echo "$debian"; fi

# RHEL, Fedora, CentOS
rhel=$(yum list installed 2>/dev/null || dnf list installed 2>/dev/null)
if [ "$rhel" ]; then fuOK && echo "$rhel"; fi

# RPM
rpm=$(rpm -qa 2>/dev/null)
if [ "$rpm" ]; then fuOK && echo "$rpm"; fi

# openSUSE
opensuse=$(zypper se --installed-only 2>/dev/null)
if [ "$opensuse" ]; then fuOK && echo "$opensuse"; fi

# Snap
snap=$(snap list 2>/dev/null)
if [ "$snap" ]; then fuOK && echo "$snap"; fi

# Flatpak
flatpak=$(flatpak list --app 2>/dev/null)
if [ "$flatpak" ]; then fuOK && echo "$flatpak"; fi

}


#####################
# Interesting Files #
#####################

interesting_files() {

fuTITLE "Interesting files"
sleep 1

# useful binaries
fuCHECKS "Useful tools / binaries for further investigation"
echo
command -v nc 2>/dev/null ; command -v netcat 2>/dev/null ; command -v wget 2>/dev/null ; command -v nmap 2>/dev/null ; command -v gcc 2>/dev/null; command -v curl 2>/dev/null

# suid, guid, sticky bit
# suid files
fuCHECKS "Files with SUID bit set"
suid=$(find / -perm -4000 -type f 2>/dev/null)
if [ "$suid" ]; then fuOK && echo "$suid"; else fuNOTOK; fi

# guid files
fuCHECKS "Files with GUID bit set"
guid=$(find / -perm -2000 -type f 2>/dev/null)
if [ "$guid" ]; then fuOK && echo "$guid"; else fuNOTOK; fi

# sticky bit files
fuCHECKS "Files with STICKY bit set"
sticky=$(find / -perm -1000 -type f 2>/dev/null)
if [ "$sticky" ]; then fuOK && echo "$sticky"; else fuNOTOK; fi

# sticky bit directories
fuCHECKS "Directories with STICKY bit set"
stickyd=$(find / -perm -1000 -type d 2>/dev/null)
if [ "$stickyd" ]; then fuOK && echo "$stickyd"; else fuNOTOK; fi


# history files
# user history
fuCHECKS "Current user's history files"
userhistory=$(ls -la $HOME/.*_history 2>/dev/null)
if [ "$userhistory" ]; then fuOK && echo "$userhistory"; else fuNOTOK; fi

# roots history
fuCHECKS "Root's history files"
roothistory=$(ls -la /root/.*_history 2>/dev/null)
if [ "$roothistory" ]; then fuOK && echo "$roothistory"; else fuNOTOK; fi

# bash history files
fuCHECKS "Other bash history files"
bashhistory=$(find /home -name .bash_history 2>/dev/null)
if [ "$bashhistory" ]; then fuOK && echo "$bashhistory"; else fuNOTOK; fi


# private keys
fuCHECKS "Private keys"
privatekeys=$(grep -rl "PRIVATE KEY-----" /home 2>/dev/null)
if [ "$privatekeys" ]; then fuOK && echo "$privatekeys"; else fuNOTOK; fi

# git files
fuCHECKS "Git credential files"
gitfiles=$(find / -name ".git-credentials" 2>/dev/null)
if [ "$gitfiles" ]; then fuOK && echo "$gitfiles"; else fuNOTOK; fi

# .plan files
fuCHECKS "Files with .plan extension"
planfiles=$(find / -iname *.plan -exec ls -la {} 2>/dev/null \;)
if [ "$planfiles" ]; then fuOK && echo "$planfiles"; else fuNOTOK; fi

# bak files
fuCHECKS "Files with .bak extension"
bakfiles=$(find / -name *.bak -type f 2>/dev/null)
if [ "$bakfiles" ]; then fuOK && echo "$bakfiles"; else fuNOTOK; fi

# mail
fuCHECKS "Accessible mail files"
mails=$(ls -la /var/mail 2>/dev/null)
if [ "$mails" ]; then fuOK && echo "$mails"; else fuNOTOK; fi


# List Mozilla Firefox Bookmark Database Files on Linux
fuCHECKS "List firefox bookmarks"
firefox=$(find / -path "*.mozilla/firefox/*/places.sqlite" 2>/dev/null)
if [ "$firefox" ]; then fuOK && echo "$firefox"; else fuNOTOK; fi

}


####################
# Container Checks #
####################

container_info() {

fuTITLE "Information about containers"
sleep 1

# Docker
# check if we are in a docker container
fuCHECKS "Check if we are in a docker container"
dockercontainer=$(grep -i docker /proc/self/cgroup 2>/dev/null || grep -i docker /proc/1/cgroup 2>/dev/null ; find / -iname "*dockerenv*" 2>/dev/null)
if [ "$dockercontainer" ]; then fuOK && echo "$dockercontainer"; else fuNOTOK; fi

# check if we are a docker host
fuCHECKS "Check if we are a docker host"
dockerhost=$(docker --version 2>/dev/null ; docker ps -a 2>/dev/null)
if [ "$dockerhost" ]; then fuOK && echo "$dockerhost"; else fuNOTOK; fi

# check if we are member of a docker group
fuCHECKS "Check if we are member of a docker group"
dockergroup=$(id | grep -i docker 2>/dev/null)
if [ "$dockergroup" ]; then fuOK && echo "$dockergroup"; else fuNOTOK; fi

# look for any docker files
fuCHECKS "Check if there are any docker files"
dockerfiles=$(find / -iname *Dockerfile* 2>/dev/null ; find / -iname *docker-compose* 2>/dev/null)
if [ "$dockerfiles" ]; then fuOK && echo "$dockerfiles"; else fuNOTOK; fi

# LXC Container
# check if we are in a lxc container
fuCHECKS "Check if we are in a lxc container"
lxccontainer=$(grep -qa container=lxc /proc/1/environ 2>/dev/null || grep -i lxc /proc/1/cgroup 2>/dev/null)
if [ "$lxccontainer" ]; then fuOK && echo "$lxccontainer"; else fuNOTOK; fi

# check if we are member of a lxc group
fuCHECKS "Check if we are member of a lxc group"
lxcgroup=$(id | grep -i lxc 2>/dev/null)
if [ "$lxcgroup" ]; then fuOK && echo "$lxcgroup"; else fuNOTOK; fi

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

run_all | tee ${hostname}_all_info.txt

fuINFO "Internal Recon complete"


#####################
# Summarize Results #
#####################

fuTITLE "Output in following files:"
if [ -s "$mySYSTEMFILE" ]; then
  fuRESULT "System information written to: $BYELLOW$mySYSTEMFILE$NC"
fi
if [ -s "$myNETWFILE" ]; then
  fuRESULT "Network information written to: $BYELLOW$myNETWFILE$NC"
fi
if [ -s "$myUSERFILE" ]; then
  fuRESULT "User information written to: $BYELLOW$myUSERFILE$NC"
fi
if [ -s "$myJOBSFILE" ]; then
  fuRESULT "Jobs / Tasks information written to: $BYELLOW$myJOBSFILE$NC"
fi
if [ -s "$mySERVICESFILE" ]; then
  fuRESULT "Service / Process information written to: $BYELLOW$mySERVICESFILE$NC"
fi
if [ -s "$mySOFTWAREFILE" ]; then
  fuRESULT "Software information written to: $BYELLOW$mySOFTWAREFILE$NC"
fi
if [ -s "$myINTERESTFILE" ]; then
  fuRESULT "Information about interesting files written to: $BYELLOW$myINTERESTFILE$NC"
fi
if [ -s "$myCONTAINERFILE" ]; then
  fuRESULT "Information about containers written to: $BYELLOW$myCONTAINERFILE$NC"
fi
if [ -s "${hostname}_all_info.txt" ]; then
  fuRESULT "Report (all information together) written to: $BYELLOW${hostname}_all_info.txt$NC"
fi
echo


##############
# Next Steps #
##############
  
echo "
   _   _           _     ____  _                   _____       ____                
  | \ | | _____  _| |_  / ___|| |_ ___ _ __  ___  |_   _|__   |  _ \  ___          
  |  \| |/ _ \ \/ / __| \___ \| __/ _ \ '_ \/ __|   | |/ _ \  | | | |/ _ \         
  | |\  |  __/>  <| |_   ___) | ||  __/ |_) \__ \   | | (_) | | |_| | (_) |  _ _ _ 
  |_| \_|\___/_/\_\ __| |____/ \__\___| .__/|___/   |_|\___/  |____/ \___/  (_|_|_)
                                      |_|                                          
"

fuSTEPS "Checkout the found information in one of the files created in the current directory."
# more to do

echo