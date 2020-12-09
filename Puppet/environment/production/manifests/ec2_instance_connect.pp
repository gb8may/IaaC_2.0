package { 'ec2-instance-connect':
  ensure => present,
}

service { 'ec2-instance-connect':
  ensure => running,
  enable => true,
}
