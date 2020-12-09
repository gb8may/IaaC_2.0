ec2_instance { 'DevOps_Server' :
  ensure		   => 'running',
  image_id		   => 'ami-00ddb0e5626798373',
  instance_type		   => 't2.micro',
  key_name		   => ['New_Pair_Mac'],
  iam_instance_profile_arn => 'arn:aws:iam::868669587970:instance-profile/ssh_access_profile',
  monitoring		   => 'false',
  region		   => 'us-east-1',
  security_groups	   => ['Clone_Env_Develop'],
  subnet		   => ['DevOps_Env_Subnet'],
  user_data 		   => "${templatefile("ec2_instance_connect.sh.erb"}",
  tags			   => {'Name' => 'DevOps_Server'},
}
