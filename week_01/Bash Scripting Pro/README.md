# Bash Scripting Pro

## Project Overview
This project automates the deployment of a LAMP stack using a Bash script called `deploy_lamp.sh`.

The goal is to turn repetitive server setup tasks into a reliable, repeatable automation process that installs, secures, and validates a Linux web server environment.

## What it does
- Verifies the script is running as `root`
- Installs:
  - Apache
  - MariaDB
  - PHP
- Applies basic hardening:
  - removes the default MariaDB test database
  - configures firewall rules
- Uses `set -e` to stop on error
- Shows colored status messages:
  - green for success
  - red for failure
- Validates the deployment by performing a local `curl` request and confirming a `200 OK` response

## Requirements
- Linux environment compatible with Bash
- root privileges to install packages and modify firewall settings
- internet access to fetch packages
- `curl` installed for validation

## Repository Structure
- `deploy_lamp.sh` — main deployment script
- `WALKTHROUGH.md` — step-by-step guide for execution
- `img/` — optional screenshots or diagrams

## Usage
1. Make the script executable:
   ```bash
   chmod +x deploy_lamp.sh
   ```
This enables centralized log access for auditing and troubleshooting.

## Version Control
Keep all key configuration files under Git version control, especially:

- `nginx.conf`
- Nginx site definition files
- firewall configuration scripts

## Additional Documentation
For the full setup procedure, configuration details, and execution steps, refer to:

- `WALKTHROUGH.md`

## Authoring
This project is part of a DevOps/Cloud learning path focused on secure service segmentation, reproducible infrastructure, and configuration management.