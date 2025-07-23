#!/bin/bash
set -e

USER_HOME="/home/vagrant"
PUBKEY_CONTENT=$(cat /vagrant/ssh_key.pub)

# Add our shared public key if not present
if ! grep -q "$PUBKEY_CONTENT" $USER_HOME/.ssh/authorized_keys; then
    echo "$PUBKEY_CONTENT" >> $USER_HOME/.ssh/authorized_keys
    chown vagrant:vagrant $USER_HOME/.ssh/authorized_keys
    chmod 600 $USER_HOME/.ssh/authorized_keys
fi

# Ensure SSH server is running
sudo systemctl enable ssh
sudo systemctl restart ssh

# Optional: Install any extra packages here
