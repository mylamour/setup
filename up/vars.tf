variable "region" {
    default = "ap-northeast-1"
}

variable "instancetype" {
    default = "t3.micro"
}

variable "securitygroup" {
    default = "sg-9161f3f7"
}

variable "rootbolcksize" {
    default = "20"
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