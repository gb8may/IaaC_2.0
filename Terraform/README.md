PUPPET PROCEDURE

MASTER
apt update
apt upgrade

https://puppet.com/docs/puppet/latest/puppet_platform.html#task-383
wget https://apt.puppet.com/puppet6-release-bionic.deb
dpkg -i puppet6-release-bionic.deb
apt update


https://puppet.com/docs/puppetserver/latest/install_from_packages.html
apt install puppetserver
vi /etc/hosts
IP puppetmaster
IP puppet
IP puppetmaster.stopitsomemore.com
IP puppet.stopitsomemore.com
IP puppetdb.stopitsomemore.com
IP puppetdb


https://puppet.com/docs/puppet/latest/config_file_main.html
vi /etc/puppetlabs/puppet/puppet.conf
[master]
dns_alt_names = puppetmaster,puppetmaster.ec2instance.com,puppet,puppet.ec2instance.com

[main]
certname = puppetmaster.ec2instance.com
server = puppetmaster
runinterval = 1h
strict_variables = true


systemctl start puppetserver
systemctl enable puppetserver

cd /opt/puppetlabs/puppet/bin/
./puppet agent --test


AGENT
https://puppet.com/docs/puppet/latest/puppet_platform.html#task-383
cd /tmp
wget https://apt.puppet.com/puppet6-release-bionic.deb
dpkg -i puppet6-release-bionic.deb
apt update

apt install puppet-agent
vi /etc/hosts
IP puppetmaster
IP puppet
IP puppetmaster.ec2instance.com
IP puppet.ec2instance.com

https://puppet.com/docs/puppet/latest/config_file_main.html
vi /etc/puppetlabs/puppet/puppet.conf
[main]
certname = puppetagent.ec2instance.com
server = puppetmaster
runinterval = 1h
environment = production


cd /opt/puppetlabs/puppet/bin
./puppet agent --test


MASTER
cd /opt/puppetlabs/server/bin
./puppetserver ca list
./puppetserver ca sign --certname puppetagent.ec2instance.com
./puppetserver ca sign --all


AGENT 
./puppet agent --test


MASTER BASIC Manifest

vi /etc/puppetlabs/code/environments/production/manifests/apache2.pp
package { 'apache2':
  ensure => present,
}

service { 'apache2':
  ensure => running,
  enable => true,
}
