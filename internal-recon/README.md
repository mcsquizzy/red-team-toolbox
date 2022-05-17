# Internal Reconnaissance Phase

Definition...  

## Usage

From github:
```sh
curl -LJO https://github.com/McSquizzy/red-team-toolbox/blob/main/internal-recon/internal-recon.sh
sh internal-recon.sh
```
Local network:
```sh
# Host
sh internal-recon.sh -w
# Target
curl -LJO <Host>:8000/internal-recon.sh
sh internal-recon.sh
```

### Parameters

```sh
sh internal-recon.sh -h

Usage: internal-recon.sh [options]

Options:
-h    Show this help message
-w    Serves an local web server for transferring files

Output:
-c    No colours. Without colours, the output can probably be read better
-q    Quiet. No banner and no advisory displayed
```

## Checks

Script collecting information about:  

- System
- Network
- User & groups
- Jobs/tasks
- Services/processes
- Software
- Interesting files
- Container

## Results

Results saved to files in current directory and printed to stdout.

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
