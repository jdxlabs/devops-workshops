output "bastion" {
  value = "${aws_instance.bastion.0.public_ip}"
}

output "consul_masters" {
  value = ["${aws_instance.consul_masters.*.private_ip}"]
}

output "logstores" {
  value = ["${aws_instance.logstores.*.public_ip}"]
}
