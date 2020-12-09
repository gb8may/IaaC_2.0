ec2_instance { 'SSH_Server':
  ensure            => running,
  region            => 'us-east-1',
  availability_zone => 'us-east-1a',
  image_id          => 'ami-0885b1f6bd170450c', # Ubuntu Server 20.04 LTS (HVM), SSD Volume Type
  instance_type     => 't2.micro',
  subnet            => 'subnet-5102ff70',
  security_groups   => ['sg-09aaa34add79f3a93'],
  tags              => {
    tag_name => 'SSH_Server',
  },
}
