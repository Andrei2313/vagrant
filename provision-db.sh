#!/bin/bash

sudo apt update
sudo apt install -y mongodb

# Enable and start MongoDB
sudo systemctl enable mongodb
sudo systemctl start mongodb

# Allow external connections (bind to all interfaces)
sudo sed -i 's/bind_ip = 127.0.0.1/bind_ip = 0.0.0.0/' /etc/mongodb.conf
sudo systemctl restart mongodb
