#!/bin/bash

# Setup Node.js 18 (corect)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs nginx

# Fix pt comanda `node` (dacă lipsește)
if ! command -v node &> /dev/null; then
    sudo ln -s /usr/bin/nodejs /usr/bin/node
fi

# Navighează în aplicație și instalează deps
cd /home/vagrant/app
npm install

# Config Nginx reverse proxy
sudo rm /etc/nginx/sites-enabled/default
cat <<EOF | sudo tee /etc/nginx/sites-available/todo
server {
    listen 80;
    server_name todo.local;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/todo /etc/nginx/sites-enabled/
sudo systemctl restart nginx
