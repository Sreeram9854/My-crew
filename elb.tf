resource "aws_vpc" "default" {
    cidr_block = var.vpc_cidr

    tags = {
        Name = "terraform-aws-vpc"
    }
}

resource "aws_internet_gateway" "default" {
    vpc_id = aws_vpc.default.id
}

resource "aws_subnet" "public" {
  vpc_id  = aws_vpc.default.id
  cidr_block = var.public_subnet_cidr
  map_public_ip_on_launch = "true"
  tags = {
    name = "public"
  }
 }

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
  tags = {
     name = "public"
  }
 }

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "default" {
  name = "test"
  vpc_id = aws_vpc.default.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port  = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}

    tags = {
        Name = "TESTSG"
    }
 }

resource "aws_instance" "test1" {
  ami = var.ami
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.default.id]
  associate_public_ip_address = true
  key_name = var.aws_key_name
  user_data = <<-EOF
#!/bin/bash
sudo apt-get update
echo 'Hello from server-1, I am WEB-1!!!!' >index.html
nohup busybox httpd -f -p 80 &
EOF

  tags = {
    name = "test1"
   }
 }

resource "aws_instance" "test2" {
  ami = var.ami
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.default.id]
  associate_public_ip_address = true
  key_name = var.aws_key_name
  user_data = <<-EOF
#!/bin/bash
sudo apt-get update
echo 'Hello from server-2, I am WEB-2!!!' >index.html
nohup busybox httpd -f -p 80 &
EOF

  tags = {
    name = "test2"
   }
 }

resource "aws_elb" "test" {
  name = "test-elb"
  subnets = [aws_subnet.public.id]
  security_groups = [aws_security_group.default.id]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port  = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold  = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "http:80/"
    interval = 30
  }

  instances                   = [aws_instance.test1.id , aws_instance.test2.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "TestApp-terraform-elb"
  }
}

resource "aws_dynamodb_table" "tflocktable" {
 hash_key = "LockID"
 name = "tflocktable"
 read_capacity = 5
 write_capacity = 5
 attribute {
   name = "LockID"
   type = "S"
 }
}

#################################################################################################################

#count=2 #(where X is number of instances
#tags {
#Name="${format("test-%01d",count.index+1)}"
#}
