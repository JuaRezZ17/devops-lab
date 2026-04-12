#!/bin/bash
# 4. Error handling
set -e

echo "[INFO] Starting deployment of the LAMP stack..."

# 1. User check
if [[ $EUID -ne 0 ]]; then
   echo "[ERROR] This script must be run as root or using sudo."
   exit 1
fi
echo "[INFO] Root verification successful."

# 2. Installation
echo "[INFO] Updating repositories and installing packages..."
apt update -y
apt install -y apache2 mariadb-server php libapache2-mod-php php-mysql

# Ensuring that the services are installed
systemctl start apache2
systemctl enable apache2
systemctl start mariadb
systemctl enable mariadb

# 3. Security
echo "[INFO] Applying security settings..."

# Delete anonymous users and the MariaDB test database
mysql -e "DELETE FROM mysql.user WHERE User='';"
mysql -e "DROP DATABASE IF EXISTS test;"
mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
mysql -e "FLUSH PRIVILEGES;"

# Firewall configuration (UFW)
echo "[INFO] Configuring firewall rules..."
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

# 5. Validation
echo "[INFO] Validating the server's response..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)

if [ "$HTTP_CODE" -eq 200 ]; then
    echo "[SUCCESS] Validation successful: The server returns a 200 OK response."
    echo "[INFO] Deployment completed successfully."
else
    echo "[ERROR] Validation failed. The server responded with: $HTTP_CODE"
    exit 1
fi
