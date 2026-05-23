#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "Welcome to AWS HA Architecture! Served from: $(hostname -f)" > /var/www/html/index.html