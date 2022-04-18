# Reconnaissance Phase

Definition

Available parts:
- Identity
- Host
- Network
- Vulnerability

## Quick Start

1. Copy the `reconnaissance.conf.dist` file to `reconnaissance.conf`
```
cp ./reconnaissance.conf.dist reconnaissance.conf
```
1. Adjust the conf file to your needs
1. Run the script with following command:
```
./reconnaissance.sh --conf=reconnaissance.conf
```

## Results

Results stored to output/ directory

## Spoofing

All nmap scans can be provided with obfuscation/spoofing technique. 

## Tools

All tools used are preinstalled on latest Kali Linux Version 2022.1:  
- sherlock
- spiderfoot
- whois
- dnsenum
#- amass
- fping
- netdiscover
- nmap
- gobuster
- smbmap
- nikto