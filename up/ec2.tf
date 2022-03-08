provider "aws" {
    region = "${var.region}"
}

resource "aws_key_pair" "local" {
  key_name   = "local"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_instance" "testecs" {
  // if you use different ami please changed the user
  ami                = "${data.aws_ami.ubuntu.id}"
  instance_type      = "${var.instancetype}"
  vpc_security_group_ids    = ["${var.securitygroup}"]
  key_name = "${aws_key_pair.local.key_name}"

  count = "${var.instacescount}"

  root_block_device {
    volume_size           = "${var.rootbolcksize}"
    volume_type           = "gp2"
    delete_on_termination = true
  }

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