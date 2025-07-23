VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # === VM pentru BAZA DE DATE ===
  config.vm.define "db" do |db|
    db.vm.box = "ubuntu/bionic64"
    db.vm.hostname = "db"
    db.vm.network "private_network", ip: "192.168.56.10"

    db.vm.provision "shell", inline: <<-SHELL
      sudo apt update
      sudo apt install -y mongodb
      sudo sed -i 's/bind_ip = 127.0.0.1/bind_ip = 0.0.0.0/' /etc/mongodb.conf
      sudo systemctl restart mongodb
      sudo systemctl enable mongodb
    SHELL
  end

  # === VM pentru APLICAȚIE ===
  config.vm.define "app" do |app|
    app.vm.box = "ubuntu/bionic64"
    app.vm.hostname = "app"
    app.vm.network "private_network", ip: "192.168.56.11"
    app.vm.network "forwarded_port", guest: 3000, host: 3000  # fallback
    app.vm.provision "shell", inline: <<-SHELL
      # Copiază aplicația din /vagrant/app în VM (o singură dată)
      if [ ! -d "/home/vagrant/app" ]; then
        mkdir /home/vagrant/app
        cp -r /vagrant/app/* /home/vagrant/app/
      fi

      # Instalează Node.js 16 și nginx
      curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
      sudo apt install -y nodejs npm nginx

      # Instalează deps
      cd /home/vagrant/app
      npm install

      # Modifică aplicația să se conecteze la DB VM
      sed -i 's|mongodb://localhost:27017|mongodb://192.168.56.10:27017|' index.js

      # Configurare NGINX reverse proxy
      sudo rm -f /etc/nginx/sites-enabled/default
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
      sudo ln -s /etc/nginx/sites-available/todo /etc/nginx/sites-enabled/todo
      sudo systemctl restart nginx
    SHELL
  end

end
