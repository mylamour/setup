// Temporarily use root block_device but not ebs


// resource "aws_volume_attachment" "ebs_att" {
//   device_name = "/dev/sdh"
//   volume_id   = aws_ebs_volume.ebstore.id
//   instance_id = aws_instance.testecs.id
// }

// resource "aws_ebs_volume" "ebstore" {
//   availability_zone = "${var.region}"
//   size              = 50
// }

// resource "aws_ebs_volume" "vol_generic_data" {
//   size              = 120
//   count             = "${var.node_count}"
//   type              = "gp2"
// }

// resource "aws_volume_attachment" "generic_data_vol_att" {
//   device_name = "/dev/xvdf"
//   volume_id   = "${element(aws_ebs_volume.vol_generic_data.*.id, count.index)}"
//   instance_id = "${element(aws_instance.vol_generic_data.*.id, count.index)}"
//   count       = "${var.node_count}"
// }