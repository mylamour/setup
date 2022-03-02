output "image_id" {
    value = "${data.aws_ami.ubuntu.id}"
}

output "test_server_ip" {
    value = "${aws_instance.testecs.public_ip}"
}