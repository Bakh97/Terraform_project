#!/bin/bash

# Update package lists
apt update -y

# Install Apache and AWS CLI in non-interactive mode
DEBIAN_FRONTEND=noninteractive apt install -y apache2 awscli

# Get the instance ID using the instance metadata
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Verify Apache installation before proceeding
if ! systemctl is-active --quiet apache2; then
    echo "Apache installation failed. Exiting script."
    exit 1
fi

# Download the images from the S3 bucket (ensure IAM permissions are set)
# Uncomment the following line if you need to download an image
# aws s3 cp s3://myterraformprojectbucket2023/project.webp /var/www/html/project.png --acl public-read

# Create a simple HTML file with the portfolio content and display the images
cat <<"EOF" > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
  <title>My Portfolio</title>
  <style>
    @keyframes colorChange {
      0% { color: red; }
      50% { color: green; }
      100% { color: blue; }
    }
    h1 {
      animation: colorChange 2s infinite;
    }
  </style>
</head>
<body>
  <h1>Terraform Project Server 1</h1>
  <h2>Instance ID: <span style="color:green">'"$INSTANCE_ID"'</span></h2>
  <p>Welcome to Bakhsinder's Webserver_1 </p>
</body>
</html>
EOF

# Restart Apache and enable it on boot
systemctl restart apache2
systemctl enable apache2



