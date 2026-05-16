# ALB + Auto Scaling

## Objetive
Build a classic, scalable and fault-tolerant architecture. If a server fails, the system recovers automatically without the end user noticing any downtime.

### Launch Template: Create a ‘Launch Template’. Configure an Amazon Linux 2023 AMI (t3.micro instance type) and a UserData script that installs a web server and displays the local IP address and the Availability Zone in which it is running in the HTML.
To ensure traffic flows correctly from the internet to the instances, we are going to create two security groups:
- One for the load balancer that allows HTTP traffic from any source:

![alb_security_group](img/alb_security_group.png)

- One for the EC2 instances that allows HTTP traffic only from the load balancer’s security group. This is done for security reasons, so that the instances only receive traffic via the load balancer:

![webserver_security_group](img/webserver_security_group.png)

Now we are going to create the ‘Launch Template’. To do this, go to the EC2 console and, in the left-hand side menu, click on ‘Launch Templates’ > ‘Create launch template’ and select the following configuration:

![lt_1](img/lt_1.png)

![lt_2](img/lt_2.png)

![lt_3](img/lt_3.png)

![lt_4](img/lt_4.png)

In ‘Advanced details’, scroll down to the ‘User data’ box and enter the code from the `user_data.bash` file:

````
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
````

The most relevant lines in the file are:
- **`yum install -y httpd`:** Downloads and installs Apache, the web server.

- **`systemctl start httpd`:** Starts the web server immediately.

- **`TOKEN=$(curl -X PUT...`:** Amazon Linux 2023 uses version 2 of the instance metadata (IMDSv2) for security reasons. This line generates a temporary token required to make queries about the machine itself.

- **`LOCAL_IP=... and AZ=...`:** We use `$TOKEN` to query the AWS magic URL (169.254.169.254) for this machine’s private IP address and the physical data centre (AZ) in which it is running.

- **`echo ‘...’ > /var/www/html/index.html`:** We write the HTML code directly into the Apache public folder so that it is displayed when someone accesses the site.

### Auto Scaling Group (ASG): Create an ASG using that template. Configure it to deploy across two public subnets in two different Availability Zones. Desired Capacity: 2. Minimum: 2. Maximum: 4.
In the left-hand menu of the EC2 console, go to ‘Auto Scaling Groups’ > ‘Create Auto Scaling Group’:

![asg_1](img/asg_1.png)

![asg_2](img/asg_2.png)

![asg_3](img/asg_3.png)

![asg_4](img/asg_4.png)

![asg_5](img/asg_5.png)

### Application Load Balancer (ALB): Deploy a Layer 7 load balancer in front of your ASG. Configure a Target Group with Health Checks on port 80.
In the EC2 console menu, go to ‘Target Groups’ and create one with the following settings:

![tg_1](img/tg_1.png)

![tg_2](img/tg_2.png)

Now let’s create a “Load Balancer” of the “Application Load Balancer” type:

![lb_1](img/lb_1.png)

![lb_2](img/lb_2.png)

![lb_3](img/lb_3.png)

### Chaos Test: * Access the ALB’s public DNS from your browser. Refresh several times and observe how it balances traffic between AZ “A” and AZ “B”. Go to the EC2 console and manually terminate (destroy) one of the instances. Observe in the ASG’s activity tab how it detects that the instance has failed and automatically launches a new one to restore the desired state.
First, let’s carry out a load balancing test. To do this, go to “Load Balancers”, select `WebServerALB` and copy the DNS name:

![test_1_1](img/test_1_1.png)

We paste that URL into a new tab in our browser and, when we refresh the page, we will see that the ‘Local IP’ and the ‘Availability Zone’ switch between AZ “A” and AZ ‘B’. The ALB is balancing the traffic:

![test_1_2](img/test_1_2.png)

![test_1_3](img/test_1_3.png)

Now let’s run the chaos test. Go to “Instances” and you’ll see the two instances from the previous test. Let’s terminate one of them:

![test_2_1](img/test_2_1.png)

Go to the ‘Auto Scaling Groups’ window, select our `WebServerASG` and go to the “Activity” tab. You will see a log indicating that the ASG has detected that an instance has been terminated (it no longer meets the ‘Desired Capacity of 2’). In a few seconds, you’ll see a new event: the ASG is automatically launching a new EC2 instance to replace the failed one, ensuring that your web application regains its high availability without manual intervention:

![test_2_2](img/test_2_2.png)

![test_2_3](img/test_2_3.png)