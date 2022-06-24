# Reconnaissance Phase

The reconnaissance phase attempts to gather information about a target (person, network, host, etc.) that can be used for the upcoming phases. This includes technical as well as non-technical information, which is collected using various techniques (active and passive scanning, open source intelligence (OSINT), etc.).

This environment variables controlled bash script serves as a tool for receiving important information about a specific host or a network. The script can gain the following information:

- Identity
- Host
- Network
- Vulnerability

## Features

- Spoofing: All nmap scans can be provided with obfuscation/spoofing technique
- Bypassing Firewall Rules: Network scan tries Nmap exotic scan flags if ports are filtered
- Run as root or non-root: Both is possible, but some scans are not executed without root

## Usage

1. Copy the `reconnaissance.conf.dist` file to `reconnaissance.conf`
```
cp ./reconnaissance.conf.dist reconnaissance.conf
```
1. Adjust the conf file to your needs
1. Run the script with following command:
```
./reconnaissance.sh -c reconnaissance.conf
```

## Results

Results saved to output/ directory.

## Tools used

All tools used are preinstalled on latest Kali Linux Version 2022.1:  

- sherlock
- spiderfoot
- whois
- dnsenum
- fping
- netdiscover
- nmap
- gobuster
- smbmap
- nikto

## Adress Spoofing

Use a working network interface or an IP address that exists in the network.  

Create the following iptables rules for to change the source address:

```sh
# only for icmp packages
sudo iptables -t nat -A POSTROUTING -p icmp -j SNAT --to-source <source ip>

# for all tcp/udp packages
sudo iptables -t nat -A POSTROUTING -j SNAT --to-source <source ip>
```

Check for more information: https://sandilands.info/sgordon/address-spoofing-with-iptables-in-linux
