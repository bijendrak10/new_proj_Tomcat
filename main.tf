########### Variable ###########

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {
default = "new_devops"
}


########### Providers ###########

# Specify the provider and access details

provider "aws" {
access_key = "${var.aws_access_key}"
secret_key = "${var.aws_secret_key}"
region = "us-east-2"
}

########### Resources ###########

# Create a VPC to launch our instances into

resource "aws_vpc" "demovpc" {
  cidr_block       = "11.0.0.0/16"

  tags = {
    Name = "demovpc"
  }
}
# Create an internet gateway to give our subnet access to the outside world

resource "aws_internet_gateway" "demoigw" {
  vpc_id = "${aws_vpc.demovpc.id}"

  tags = {
    Name = "demoIGW"
  }
}

# Create a subnet to launch our instances into AZ us-east-2a

resource "aws_subnet" "demosub" {
  vpc_id     = "${aws_vpc.demovpc.id}"
  cidr_block = "11.0.1.0/24"
  availability_zone = "us-east-2a"
    tags = {
    Name = "demopubSUB"
  }
}

# Create a subnet to launch our instances into AZ us-east-2b

resource "aws_subnet" "demosubone" {
  vpc_id     = "${aws_vpc.demovpc.id}"
  cidr_block = "11.0.2.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "demopubSUBone"
  }
}

# Grant the VPC internet access on its main route table

resource "aws_route_table" "demort" {
  vpc_id = "${aws_vpc.demovpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.demoigw.id}"
  }

  tags = {
    Name = "demopubRT"
  }
}


# security group ingress ??

resource "aws_security_group" "demoSG" {
  vpc_id       = "${aws_vpc.demovpc.id}"
  name         = "demo security group"

ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 82
    to_port     = 82
    protocol    = "tcp"
  }
ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 83
    to_port     = 83
    protocol    = "tcp"
  }
ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 84
    to_port     = 84
    protocol    = "tcp"
  }

ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 81
    to_port     = 81
    protocol    = "tcp"
  }

egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
tags = {
        Name = "demosecuritygroup"
  }
}

# Associate route table to subnets of AZ us-east-2a

resource "aws_route_table_association" "demortassoc" {
  subnet_id      = "${aws_subnet.demosub.id}"
  route_table_id = "${aws_route_table.demort.id}"
}

# Associate route table to subnets of AZ us-east-2b

resource "aws_route_table_association" "demortassocone" {
  subnet_id      = "${aws_subnet.demosubone.id}"
  route_table_id = "${aws_route_table.demort.id}"
}

# Cretae instance in both the AZ subnets  

resource "aws_instance" "web" {
  instance_type = "t2.micro"
  ami = "ami-0cd3dfa4e37921605"
  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.demoSG.id}"]
  associate_public_ip_address = true
  availability_zone = "us-east-2a"
  subnet_id = "${aws_subnet.demosub.id}"
}
resource "aws_instance" "web1" {
  instance_type = "t2.micro"
  ami = "ami-0cd3dfa4e37921605"
  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.demoSG.id}"]
  associate_public_ip_address = true
  availability_zone = "us-east-2b"
  subnet_id = "${aws_subnet.demosubone.id}"
}

# ALB for the instances 

resource "aws_alb" "alb" {
  name = "terraform-demo-alb"

  subnets         = ["${aws_subnet.demosub.id}","${aws_subnet.demosubone.id}"]
  security_groups = ["${aws_security_group.demoSG.id}"]
}
resource "aws_alb_listener" "alb_listener" { 
        load_balancer_arn = "${aws_alb.alb.arn}"         
        port = 80

  default_action {    
    target_group_arn = "${aws_alb_target_group.alb_host1.arn}"
    type             = "forward"  
  }
}

# ALB listener 

resource "aws_alb_target_group" "alb_host1" {
        name    = "alb-front-host1"
        vpc_id  = "${aws_vpc.demovpc.id}"
        port = 80
        protocol = "HTTP"
}

# ALB target gorup attachment for instance in AZ us-east-2a

resource "aws_alb_target_group_attachment" "alb_attach_host1" {
  target_group_arn = "${aws_alb_target_group.alb_host1.arn}"
  port=81
  target_id="${aws_instance.web.id}"
}
resource "aws_alb_target_group_attachment" "alb_attach_host2" {
  target_group_arn = "${aws_alb_target_group.alb_host1.arn}"
  port=82
  target_id="${aws_instance.web1.id}"
}

# ALB target gorup attachment for instance in AZ us-east-2b

resource "aws_alb_target_group_attachment" "alb_attach_host3" {
  target_group_arn = "${aws_alb_target_group.alb_host1.arn}"
  port=83
  target_id="${aws_instance.web.id}"
}
resource "aws_alb_target_group_attachment" "alb_attach_host4" {
  target_group_arn = "${aws_alb_target_group.alb_host1.arn}"
  port=84
  target_id="${aws_instance.web1.id}"
}

# IAM User to Stop AWS instances

resource "aws_iam_user" "iamuser" {
  name = "aruntest"
  force_destroy="true"
}

# IAM User login profile

resource "aws_iam_user_login_profile" "this" {
  user                    = "${aws_iam_user.iamuser.name}"
  pgp_key                 = "keybase:argaurav"
  password_reset_required = "true"
}

resource "aws_iam_account_password_policy" "strict" {
  allow_users_to_change_password = "true"
}

# IAM User policy to stop instances

resource "aws_iam_user_policy" "iam_policy" {
  name = "testpolicy"
  user = "${aws_iam_user.iamuser.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:DescribeInstances"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "ec2:StopInstances"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:instance/${aws_instance.web.id}",
                "arn:aws:ec2:*:*:instance/${aws_instance.web1.id}"
            ],
			            "Effect": "Allow"
        }
]
}
EOF
}

########### Output ###########

output "aws_vpc" {
value = "${aws_vpc.demovpc.id}"
}
output "aws_instance_public_dns" {
value = ["${aws_instance.web.public_ip}","${aws_instance.web1.public_ip}"]
}
output "password" {
  value = "${aws_iam_user_login_profile.this.encrypted_password}"
}
