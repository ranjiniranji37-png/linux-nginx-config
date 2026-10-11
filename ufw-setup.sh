#!/bin/bash
# UFW firewall setup: allow only SSH (22), HTTP (80), HTTPS (443)

set -e

# Reset to a clean state
sudo ufw --force reset

# Default policy: block all incoming, allow all outgoing
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow only required ports
sudo ufw allow 22/tcp comment 'SSH'
sudo ufw allow 80/tcp comment 'HTTP'
sudo ufw allow 443/tcp comment 'HTTPS'

# Enable the firewall
sudo ufw --force enable

# Show the final rules
sudo ufw status verbose
