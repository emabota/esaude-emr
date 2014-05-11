# <img src="https://s3-eu-west-1.amazonaws.com/esaude/images/mozambican-emblem.png" height="50px"/> eSaude EMR Test Server (Ubuntu) <img src="https://s3-eu-west-1.amazonaws.com/esaude/images/mozambican-flag.png" height="45px"/>

## Setup

This infrastructure code allows you to set up eSaude EMR in a test environment in [Ubuntu](http://www.ubuntu.com/) using [Puppet](http://puppetlabs.com/).

1. Copy the deploy.sh script to your test machine
2. Run `sudo ./deploy.sh`
3. Navigate to `http://test-machine-ip:8080/openmrs` using a web browser, where `test-machine-ip` is the IP address of your test machine.

:warning:  **This is script is designed to run on a clean machine. To install eSaude EMR into an existing environment, follow the manual or Vagrant install steps [here](https://github.com/esaude/esaude-emr).**

## Troubleshooting

* If you've already got MySQL server installed on your machine, then you may need to [completely remove it](http://stackoverflow.com/questions/10853004/removing-mysql-5-5-completely) first. If you can't do that, then you'll need to edit the puppet manifest to use your current MySQL root password.