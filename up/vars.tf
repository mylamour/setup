variable "region" {
    default = "ap-northeast-1"
}

variable "num_proxies" {
  type    = number
  default = 10
}

variable "instancetype" {
    default = "t2.medium"
    // t2.micro 1c1g 0.0152$/hr
    // t2.medium 2c4g 0.0608$/hr suggested for kali
    // t2.xlarge 4c16g 0.186$/hr
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

data "aws_ami" "kali" {

    most_recent = true
    filter {
        name   = "name"
        values = ["kali-linux-2022.1-804fcc46-63fc-4eb6-85a1-50e66d6c7215"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["679593333241"]
}