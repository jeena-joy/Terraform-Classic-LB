# Classic Load Balancer using Terraform

Create an Instance
Create a directory for isolating terraform files.
```sh
mkdir ~/terraform && cd ~/terraform
```

#### Create provider.tf file.

we’re going to be using the AWS provider and that you wish to deploy your infrastructure in the “ap-south-1” region. For each provider, there are many different kinds of “resources” you can create, such as servers, databases, and load balancers.

```sh
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}
```
#### Create variable.tf file

This is used to declare the variable and pass values to terraform source code.

```sh
variable "region" {}
variable "access_key" {}
variable "secret_key" {}
variable "project" {}
variable "vpc_cidr" {}

variable "asg_count" {
  default = 2
}
```

### Create an AutoScaling and ELB

The first step is creating an ASG is to create a launch configuration, which specifies how to configure each EC2 Instance in the ASG.
The second step is creating a load balancer that is highly available and scalable is a lot of work.

#### Create launch configuration 

```sh
resource "aws_launch_configuration" "myapp" {

  name_prefix       = "myapp-"
  image_id          = "ami-011c99152163a87ae"
  instance_type     = "t2.micro"
  key_name          = "-key-name-"
  security_groups   = [ "sg-name" ]
  user_data         = file("setup.sh")
  lifecycle {
    create_before_destroy = true
  }

}
```
#### Create Autoscaling group

```sh
resource "aws_autoscaling_group" "myapp" {

  launch_configuration    =  aws_launch_configuration.myapp.id
  availability_zones      =  ["ap-south-1a" , "ap-south-1b"]
  health_check_type       = "EC2"
  min_size                = var.asg_count
  max_size                = var.asg_count
  desired_capacity        = var.asg_count
  wait_for_elb_capacity   = 2
  load_balancers          = ["myapp"]
  tag {
    key = "Name"
    propagate_at_launch = true
    value = "myapp"
  }
  lifecycle {
    create_before_destroy = true
  }
}
```

#### Create Classic Load balancer
```sh

resource "aws_elb" "classic" {
  name= "test"
  availability_zones = ["ap-south-1a" , "ap-south-1b"]

listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port= 80
    lb_protocol= "http"
  }

source_security_group = "aws_security_group.terraform-all"

health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout= 3
    target= "TCP:80"
    interval= 30
  }

  tags = {
    Name = "${var.project}-test-LB"
  }

lifecycle {
    create_before_destroy = true
  }
}
```


