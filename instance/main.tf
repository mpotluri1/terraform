#EC2 Instance
data "terraform_remote_state" "aj_vpc" {
  backend = "s3"
  config {
    bucket = "${var.remote_state_bucket}"
    key = "${var.remote_state_key}"
    region = "${var.remote_buc_reg}"
  }
}

terraform {
  backend "s3" {
    bucket = "manvi-logs"
    key = "aj-testing-terraform"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "aj_stack" {
  ami = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  availability_zone = "${var.az}"
  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${var.security_group}"]
  user_data = "${data.template_file.aj_boot.rendered}"
  subnet_id = "${data.terraform_remote_state.aj_vpc.public_subnets[0]}"
  iam_instance_profile = "${var.iamprofile}"
  associate_public_ip_address = "true"
  tags {
    Owner = "${var.owner}"//
    Name = "AJ-Dev"
    ExpirationDate = "2017-06-20"
    Environment = "Development"
    Project = "Asha-Jyothi"
  }
}

data "template_file" "aj_boot" {
  template = "${file("user_data/aj_bootstrap.sh.tpl")}"
}