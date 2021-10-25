#######################################################
# Launch Configuration
#######################################################


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


#######################################################
# Autoscaling Group 
#######################################################
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

########################################
# Classic load balancer
########################################

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

