#!/bin/bash

#######################################
#                                     #
# Puppet Master Install and Configure #
#                                     #
#######################################


echo "Updating system and Installing Puppet Master.."
sudo apt update && sudo apt upgrade -y
sudo wget https://apt.puppet.com/puppet6-release-bionic.deb
sudo dpkg -i puppet6-release-bionic.deb
sudo apt update
sudo apt install puppetserver -y
sudo mv /tmp/puppetserver /etc/default/puppetserver
