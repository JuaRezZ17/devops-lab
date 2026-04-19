# Secure Web Stack

## Project Overview
Secure Web Stack is an infrastructure lab that demonstrates a secure web delivery architecture using two virtual machines:

- **Gateway**: serves as the secure access point, handling SSH access and firewall enforcement.
- **Web Server**: isolated web host running Nginx with HTTPS.

The goal is to deploy a secure web stack with Nginx, self-signed SSL, and centralized logging via `journalctl`.

## Core Components
- `Gateway`
  - SSH for remote administration
  - Firewall configured to allow only required traffic
- `Web Server`
  - Nginx web server
  - Self-signed SSL certificate generated with `openssl`
  - Nginx logs available through Linux system logging

## Requirements
- VirtualBox or Proxmox
- Linux distribution for both VMs
- `nginx`
- `openssl`
- `systemd` / `journalctl`
- Git version control for configuration files

## Repository Structure
- `WALKTHROUGH.md` – step-by-step deployment and execution guide
- `src/`
  - `default` – default Nginx site configuration
  - `nginx.conf` – main Nginx configuration file
- `img/` – screenshots and architecture diagrams

## Deployment Summary
1. Create two VMs:
   - `gateway`
   - `web-server`
2. Configure networking so the gateway is the only external entry point.
3. Install and configure a firewall on the gateway VM.
4. Install Nginx on the web server VM.
5. Generate a self-signed SSL certificate with `openssl`.
6. Configure Nginx to serve HTTPS using the certificate and private key.
7. Verify Nginx logs via `journalctl`.

## SSL Configuration
The web server uses a self-signed certificate. Typical steps include:

- Generate a private key
- Create a certificate signing request (CSR)
- Generate a self-signed certificate with `openssl`
- Configure Nginx to use the certificate and key

## Logging
Nginx output is integrated with the system journal, allowing logs to be reviewed with:

```bash
journalctl -u nginx
```

## Version control
All key configuration files, in particular:

- `nginx.conf`
- site files and server blocks
- firewall scripts
must be kept under version control in this repository.

## Additional documentation
For the complete installation, configuration and testing procedure, see:

- `WALKTHROUGH.md`

## Authorship
Project developed as a DevOps/Cloud exercise, focusing on security, service segregation and reproducible deployment.