#!/bin/bash
# Enable pipeline failing
set -e -x
# Fetching the public hostname via the meta-data service
HOSTNAME=$(curl  http://169.254.169.254/latest/meta-data/public-hostname)
# Update packages and install nginx and git
sudo yum update -y
sudo yum install git -y
sudo amazon-linux-extras install nginx1
# Patch max hostname hash size to work with long hostnames
sudo sed -i 's#    types_hash_max_size 4096;#    types_hash_max_size 4096;\n    server_names_hash_bucket_size 128;#g' /etc/nginx/nginx.conf
# Add our custom configuration
sudo tee -a /etc/nginx/conf.d/dkt.conf > /dev/null <<EOF
server {
    listen       80;
    listen       [::]:80;
    server_name  ${HOSTNAME};
    root         /opt/dkt/html;
}
EOF
sudo chown nginx:nginx /etc/nginx/conf.d/dkt.conf
# Create a working dir
mkdir -p /opt/dkt
# And clone our repo, create symlink to the html path
git clone https://github.com/DevOpsKitchenTalks/aws-kitchen-static-site.git /opt/dkt/git
sudo ln -s /opt/dkt/git/dist /opt/dkt/html
sudo chown $(whoami):nginx -R /opt/dkt/git/dist /opt/dkt/html
# Enable and start the service
sudo systemctl enable nginx
sudo systemctl start nginx
# Profit
