# Gandalf - SSH Port Tunneller

## Overview
This script provides an easy-to-use way to establish SSH connections and set up port forwarding using configuration details specified in a YAML file. It allows users to select different SSH profiles defined in the YAML file.
## Requirements
- Ruby
- Required Gems:
  - `net/ssh`
  - `yaml`
  - `optparse`
  - `terminal-table`

## Installation
Before running the script, ensure you have the required gems installed. You can install them using the following commands:

```bash
gem install net-ssh yaml optparse terminal-table
```

## Usage
Run the script from the command line, specifying the path to the YAML configuration file and the desired profile alias.

```bash
ruby main.rb --file <path_to_yaml_config> --profile <profile_alias>
```

### Flags
- `-f`, `--file FILEPATH`: Specifies the path to the YAML configuration file.
- `-p`, `--profile STRING`: Specifies the alias of the profile to use from the YAML file.

### YAML Configuration File
The YAML file should contain one or more SSH connection profiles. Each profile can include the following fields:
- `alias`: A unique identifier for the profile.
- `host`: The hostname or IP address of the SSH server.
- `port`: The port number for the SSH connection.
- `user`: The username for the SSH connection.
- `password`: The password for the SSH connection (if applicable).
- `private_key`: The path to the SSH private key (if applicable).
- `pairs`: An array of port forwarding configurations, each with:
  - `direction`: `'L'` for local or `'R'` for remote forwarding.
  - `local`: The local port number.
  - `remote`: The remote port number.

### Example YAML File
```yaml
- alias: myserver
  host: 192.168.1.2
  port: 22
  user: user
  private_key: /path/to/private/key
  pairs:
    - direction: L
      local: 8080
      remote: 80
```