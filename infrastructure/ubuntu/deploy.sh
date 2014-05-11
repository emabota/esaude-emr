#!/bin/bash

################################################################################
# 1. Clean previous deploy
################################################################################
rm -rf ~/esaude-tmp
rm -rf /esaude

################################################################################
# 2. Create working directory for the deploy
################################################################################
mkdir ~/esaude-tmp
cd ~/esaude-tmp

################################################################################
# 3. Install puppet and the modules
################################################################################
wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
sudo dpkg -i puppetlabs-release-precise.deb
sudo apt-get update
sudo apt-get -y install puppet
puppet module install --force puppetlabs/stdlib
puppet module install --force puppetlabs/mysql

################################################################################
# 4. Download the latest source
################################################################################
curl -sL https://github.com/esaude/esaude-emr/tarball/master > master.tar.gz

################################################################################
# 5. Extract the source
################################################################################
mkdir source
tar -C source -zxvf master.tar.gz --strip-components 1

################################################################################
# 6. Create dummy mount point
################################################################################
cd source
ln -s $PWD /esaude

################################################################################
# 7. Apply the configuration
################################################################################
cd infrastructure
sudo puppet apply --verbose manifests/esaude.pp
