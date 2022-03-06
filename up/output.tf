output "image_id" {
    value = "${data.aws_ami.ubuntu.id}"
}

output "server_ip" {
    value = [for s in aws_instance.testecs : s.public_ip]
}