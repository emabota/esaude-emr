#!/bin/bash

################################################################################
# 1. Install puppet and the modules
################################################################################
wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
sudo dpkg -i puppetlabs-release-precise.deb
sudo apt-get update
sudo apt-get -y install puppet
puppet module install --force example42/puppi
puppet module install --force puppetlabs/stdlib
puppet module install --force puppetlabs/mysql
puppet module install --force example42/apache

################################################################################
# 2. Install Guest Additions
################################################################################
sudo apt-get install -y dkms linux-headers-generic linux-headers-$(uname -r)
mkdir /tmp/guest_additions
sudo mount -t iso9660 -o loop /home/esaude/VBoxGuestAdditions.iso /tmp/guest_additions

# The || true is necessary here because VBoxLinuxAdditions.run has a non-zero
# return code on headless systems.
sudo /tmp/guest_additions/VBoxLinuxAdditions.run --nox11 || true 

################################################################################
# 3. Fix up script ownership and mode
################################################################################
sudo chmod -R a+x /esaude/infrastructure/artifacts/appliance/scripts/*
sudo chown -R root:root /esaude/infrastructure/artifacts/appliance/scripts/*
