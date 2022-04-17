############
# SSH Keys #
############

#############
# Variables #
#############
# PUBKEY="ssh-dss AAAAB3NzaC1kc3MAAACBANWgx.........== user@metasploitable"
# if PUBKEY is empty, new Key Pair will be created
PUBKEY=""


    run ssh-keygen -t rsa -b 4096
    cat id_rsa.pub and copy the file contents
    echo “SSH key data” » ~/.ssh/authorized_keys
    Test you can connect using the private key without being prompted for a password


