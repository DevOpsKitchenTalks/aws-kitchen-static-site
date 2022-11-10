#!/bin/bash

set -e -x
# Package installation
yum update -y
yum install docker -y
systemctl enable docker
systemctl start docker
# Systemd
sudo tee -a /etc/systemd/system/dkt.site.service > /dev/null <<EOF
[Unit]
Description=DKT Static site (Containers and EC2)
After=docker.service
Requires=docker.service
After=dkt.site.service
Requires=dkt.site.service

[Service]
TimeoutStartSec=0
Restart=always
ExecStartPre=-/usr/bin/docker stop dkt
ExecStartPre=-/usr/bin/docker rm dkt
ExecStartPre=/usr/bin/docker pull ghcr.io/devopskitchentalks/aws-kitchen-static-site:latest
ExecStart=/usr/bin/docker run --name dkt -p 0.0.0.0:80:8080/tcp --rm ghcr.io/devopskitchentalks/aws-kitchen-static-site:latest

[Install]
WantedBy=multi-user.target
EOF
systemctl enable dkt.site
systemctl start dkt.site
