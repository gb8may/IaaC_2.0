#!/bin/bash

######################################
#                                    #
# Puppet Agent Install and Configure #
#                                    #
######################################


echo "Updating system and Installing Puppet Agent.."
sudo apt update && sudo apt upgrade -y
sudo wget https://apt.puppet.com/puppet6-release-bionic.deb
sudo dpkg -i puppet6-release-bionic.deb
sudo apt update
sudo apt install puppet-agent -y
sudo mv puppetagent.conf /etc/puppetlabs/puppet/puppet.conf
