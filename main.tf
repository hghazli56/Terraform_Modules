provider "aws"{

# where do you want to create the resources (eu-west-1)
  region = "eu-west-1"
}

module "vpc" {
  source = "./vpc"

}

module "asg" {
  source = "./asg"

}


