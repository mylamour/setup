variable "region" {
    default = "ap-northeast-1"
}

variable "instancetype" {
    default = "t2.nano"
    // t2.micro 1c1g 0.012$/hr
    // t2.medium 2c4g 0.046$/hr suggested for kali
    // t2.xlarge 4c16g 0.186$/hr
}

variable "securitygroup" {
    default = "sg-9161f3f7"
}

variable "rootbolcksize" {
    default = "9"
}

variable "modfile" { 
    default = "./configs/"
}

data "aws_ami" "ubuntu" {

    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"]
}