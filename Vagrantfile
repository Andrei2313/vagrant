Vagrantly = "" # Dummy to avoid highlighting issues

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"

  # Define both VMs with fixed private IPs
  config.vm.define "vm1" do |vm1|
    vm1.vm.hostname = "vm1"
    vm1.vm.network "private_network", ip: "192.168.56.11"

    vm1.vm.provider "virtualbox" do |v|
      v.memory = 1024
      v.cpus = 1
    end

    # Provision vm1
    vm1.vm.provision "shell" do |s|
      s.inline = <<-SHELL
        set -e

        # Generate SSH key for vagrant user if not exists (no passphrase)
        if [ ! -f /home/vagrant/.ssh/id_rsa ]; then
          ssh-keygen -t rsa -b 2048 -f /home/vagrant/.ssh/id_rsa -q -N ""
          chown vagrant:vagrant /home/vagrant/.ssh/id_rsa*
          chmod 600 /home/vagrant/.ssh/id_rsa
          chmod 644 /home/vagrant/.ssh/id_rsa.pub
        fi

        # Setup authorized_keys with own public key (allow self SSH)
        cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys || true

        # Fix permissions
        chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
        chmod 600 /home/vagrant/.ssh/authorized_keys
      SHELL
    end
  end

  config.vm.define "vm2" do |vm2|
    vm2.vm.hostname = "vm2"
    vm2.vm.network "private_network", ip: "192.168.56.12"

    vm2.vm.provider "virtualbox" do |v|
      v.memory = 1024
      v.cpus = 1
    end

    # Provision vm2
    vm2.vm.provision "shell" do |s|
      s.inline = <<-SHELL
        set -e

        # Generate SSH key for vagrant user if not exists (no passphrase)
        if [ ! -f /home/vagrant/.ssh/id_rsa ]; then
          ssh-keygen -t rsa -b 2048 -f /home/vagrant/.ssh/id_rsa -q -N ""
          chown vagrant:vagrant /home/vagrant/.ssh/id_rsa*
          chmod 600 /home/vagrant/.ssh/id_rsa
          chmod 644 /home/vagrant/.ssh/id_rsa.pub
        fi

        # Setup authorized_keys with own public key (allow self SSH)
        cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys || true

        # Fix permissions
        chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
        chmod 600 /home/vagrant/.ssh/authorized_keys
      SHELL
    end
  end

  # After both VMs are up, synchronize their public keys so they trust each other

  # Run after vm1 and vm2 have generated keys


  # Additional provisioners to sync public keys between VMs

  # on vm1: fetch vm2's public key and add it to vm1's authorized_keys
  config.vm.define "vm1" do |vm1|
    vm1.vm.provision "shell" do |s|
      s.inline = <<-SHELL
        set -e

        VM2_PUB_KEY=$(sshpass -p vagrant ssh -o StrictHostKeyChecking=no vagrant@192.168.56.12 'cat ~/.ssh/id_rsa.pub')

        if ! grep -q "$VM2_PUB_KEY" /home/vagrant/.ssh/authorized_keys; then
          echo "$VM2_PUB_KEY" >> /home/vagrant/.ssh/authorized_keys
          chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
        fi
      SHELL
    end
  end

  # on vm2: fetch vm1's public key and add it to vm2's authorized_keys
  config.vm.define "vm2" do |vm2|
    vm2.vm.provision "shell" do |s|
      s.inline = <<-SHELL
        set -e

        VM1_PUB_KEY=$(sshpass -p vagrant ssh -o StrictHostKeyChecking=no vagrant@192.168.56.11 'cat ~/.ssh/id_rsa.pub')

        if ! grep -q "$VM1_PUB_KEY" /home/vagrant/.ssh/authorized_keys; then
          echo "$VM1_PUB_KEY" >> /home/vagrant/.ssh/authorized_keys
          chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
        fi
      SHELL
    end
  end

  # Ensure sshpass is installed, which is absolutely necessary for password-based SSH inside provisioning.
  # We will do this in a synced pre-provision step on both machines:

  ["vm1", "vm2"].each do |name|
    config.vm.define name do |machine|
      machine.vm.provision "shell" do |s|
        s.inline = <<-SHELL
          set -e
          sudo apt-get update -y
          sudo apt-get install -y sshpass
        SHELL
      end
    end
  end

  # Also ensure ssh service is running
  ["vm1", "vm2"].each do |name|
    config.vm.define name do |machine|
      machine.vm.provision "shell" do |s|
        s.inline = <<-SHELL
          set -e
          sudo systemctl enable ssh
          sudo systemctl restart ssh
        SHELL
      end
    end
  end
end
