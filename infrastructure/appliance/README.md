# <img src="https://s3-eu-west-1.amazonaws.com/esaude/images/mozambican-emblem.png" height="50px"/> eSaude EMR Appliance <img src="https://s3-eu-west-1.amazonaws.com/esaude/images/mozambican-flag.png" height="45px"/>

## Overview

This infrastructure code allows you to build the eSaude EMR appliance using [Packer](http://www.packer.io/). You will either need an Internet connection to build the appliance or you will have to pre-download some resources and run an [Apt-Cacher Server](https://help.ubuntu.com/community/Apt-Cacher-Server) (see the **Optimization** section).

## Setup

The [Packer](http://www.packer.io/) template in this repository uses the [VirtualBox](https://www.virtualbox.org/) builder and [Puppet](http://puppetlabs.com/) provisioner. In order to build the appliance you need the following software installed:

* [Packer](http://www.packer.io/) (tested with v0.6.0)
* [VirtualBox](https://www.virtualbox.org/) (tested with v4.3.10r93012)

[Puppet](http://puppetlabs.com/) will automatically be installed on the appliance. You don't need it on your host machine.

Further, you will need the [Ubuntu Server 12.04.4 image](http://releases.ubuntu.com/12.04.4/ubuntu-12.04.4-server-i386.iso) (tested with 32bit). Download the image and place it in the same directory as the `esaude-emr-appliance.json` file (or edit the value of `iso_url` in the latter file to match the location of your ISO). You may also need to edit the `iso_checksum` value to match the md5 checksum of your ISO image.

## Building

Once you've installed [Packer](http://www.packer.io/) and [VirtualBox](https://www.virtualbox.org/) and downloaded the [Ubuntu Server 12.04.4 image](http://releases.ubuntu.com/12.04.4/ubuntu-12.04.4-server-i386.iso), you're ready to build the appliance. To do so, you'll need to clone this repository, navigate to this directory and run the `esaude-emr-appliance.json` file with [Packer](http://www.packer.io/). This can be done as follows:

````
	$ git clone https://github.com/esaude/esaude-emr.git
	$ cd infrastructure/appliance
	$ packer build esaude-emr-appliance.json
````

You'll see some warnings like:

> esaude-emr: **Warning: Setting templatedir is deprecated. See http://links.puppetlabs.com/env-settings-deprecations**

These are due to a bug in the current version of Puppet that won't be fixed. See [here](https://tickets.puppetlabs.com/browse/PUP-2566) for more details.

The build can take a while, but when it's done you'll find the resulting OVA file in the `output-esaude-emr` directory.

## Optimization

#### Pre-downloading Resources

A few resources are needed to install eSaude EMR. They are:

* [The eSaude EMR Database](https://s3-eu-west-1.amazonaws.com/esaude/esaude-emr/deploy-artifacts/esaude-clean-database.sql.zip)
* [The OpenMRS core WAR file](https://s3-eu-west-1.amazonaws.com/esaude/esaude-emr/deploy-artifacts/openmrs.war)
* [The eSaude EMR Modules](https://s3-eu-west-1.amazonaws.com/esaude/esaude-emr/deploy-artifacts/esaude-emr-modules.zip)

While [Puppet](http://puppetlabs.com/) will automatically download these resources to the appliance, it may be useful to download these three resources and put them in the `infrastructure/artifacts` directory. This is especially useful if you are making changes the appliance and need to build it multiple times.

#### Using an Apt-Cacher Server

If you use an [Apt-Cacher Server](https://help.ubuntu.com/community/Apt-Cacher-Server) to speed up provisioning, you can enable it in the `esaude-emr-preseed.cfg` file in the `infrastructure/artifacts/appliance` directory by change the line:

````
	d-i mirror/http/proxy string
````

to

````
	d-i mirror/http/proxy string http://YOUR.APT.CACHER.IP:PORT/
````

where `YOUR.APT.CACHER.IP:PORT` is the IP address and port of your [Apt-Cacher Server](https://help.ubuntu.com/community/Apt-Cacher-Server).

## Troubleshooting

#### Visual Output

If you want to see the VM as it's being set up, change the value of `headless` in the `esaude-emr-appliance.json` file to `false`.

#### SSH Timeout

If you get an error that looks like:

> **==> Build 'esaude-emr' errored: Timeout waiting for SSH.**

It means that the value for `ssh_wait_timeout` in `esaude-emr-appliance.json` isn't high enough. It's currently set to `10m` (ten minutes), but if you're on a slow Internet connection (or aren't using an [Apt-Cacher Server](https://help.ubuntu.com/community/Apt-Cacher-Server)) or your machine just takes longer than ten minutes to install Ubuntu, increase the value to something like `20m` (twenty minutes) or `60m` (an hour).

#### Guest Not Running

If you see something like:

> **==> esaude-emr: Error sending boot command: VBoxManage error: VBoxManage: error: Guest not running**

Check the `VBox.log` file for the VM. If you see the following in the log:

> PDM: Failed to construct 'e1000'/0! VERR_INTNET_INCOMPATIBLE_FLAGS (-3604) - The network already exists with a different security profile (restricted / public).

It could mean that you're running another VM using bridged networking, so [Packer](http://www.packer.io/) can't create the bridged interface. Shut down any other virtual machines and it should work.
