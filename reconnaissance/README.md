# Reconnaissance Phase

Definition

Available parts:
- Identity
- Host
- Network
- Vulnerability

## User manual

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

Tools used:  
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