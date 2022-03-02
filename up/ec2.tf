provider "aws" {
    region = "${var.region}"
}

resource "aws_key_pair" "local" {
  key_name   = "local"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_instance" "testecs" {
  ami                = "${data.aws_ami.ubuntu.id}"
  instance_type      = "${var.instancetype}"
  vpc_security_group_ids    = ["${var.securitygroup}"]
  key_name = "${aws_key_pair.local.key_name}"

  // provisioner "local-exec" {
  //   command = "echo ${aws_instance.testecs.public_ip} >> ip_address.txt"
  // }

  // user_data = "${file(".tmp.sync.sh")}"
  
  connection {
    type     = "ssh"
    user     = "ubuntu"
    host     = self.public_ip
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "file" {
    source      = "${var.modfile}"
    destination = "/tmp/"
  }

  // provisioner "file" {
  //   source      = "${var.configdir['local}"
  //   destination = "${var.configdir['remote}"
  // }

  // provisioner "remote-exec" {
  //   inline = [
  //     "sudo bash /tmp/init" ,
  //   ]
  // }
}