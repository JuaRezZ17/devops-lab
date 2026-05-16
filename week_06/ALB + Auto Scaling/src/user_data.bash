#!/bin/bash
# 1. Update the system and install the Apache web server
yum update -y
yum install -y httpd

# 2. Start and enable the service so that it starts with the instance
systemctl start httpd
systemctl enable httpd

# 3. Obtain the IMDSv2 token (required on Amazon Linux 2023)
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# 4. Get the local IP address and the Availability Zone
LOCAL_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4)
AZ=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/availability-zone)

# 5. Create the index.html file containing the information
echo "<h1>Welcome to my Web Server</h1>" > /var/www/html/index.html
echo "<p><b>Local IP:</b> $LOCAL_IP</p>" >> /var/www/html/index.html
echo "<p><b>Availability Zone (AZ):</b> $AZ</p>" >> /var/www/html/index.html