################################################ Create load balancer (app)
resource "aws_elb" "app_elb" {
  name = "eng114-hamza-terraform-elb"
  security_groups = ["${aws_security_group.app.id}"]
  subnets = ["${aws_subnet.terraform_public_subnet.id}"]
  cross_zone_load_balancing   = true
  
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:80/"
  }
  
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "80"
    instance_protocol = "http"
   }
  }


##########################################################Create launch template
  resource "aws_launch_configuration" "app" {
  name_prefix = "eng114-terraform-ASG-app-"
  image_id = "ami-0b47105e3d7fc023e" 
  instance_type = "t2.micro"
  key_name = "hmz-ans"
  security_groups = [ "${aws_security_group.app.id}" ]
  associate_public_ip_address = true
  
  lifecycle {
    create_before_destroy = true
  }
}


#############################################################Create auto scaling group
resource "aws_autoscaling_group" "app" {
  name = "${aws_launch_configuration.app.name}-asg"
  min_size             = 2
  desired_capacity     = 2
  max_size             = 3
  

  load_balancers = ["${aws_elb.app_elb.id}"]
  launch_configuration = "${aws_launch_configuration.app.name}"
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]
  metrics_granularity = "1Minute"
  vpc_zone_identifier  = ["${aws_subnet.terraform_public_subnet.id}"]# Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }
  tag {
    key                 = "Name"
    value               = "eng114-hamza-terraform-app-asg"
    propagate_at_launch = true
  }
  
  }