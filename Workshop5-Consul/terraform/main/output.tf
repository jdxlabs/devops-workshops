output "bastion" {
  value = "${aws_instance.bastion.0.public_ip}"
}

output "consul_masters" {
  value = ["${aws_instance.consul_masters.*.private_ip}"]
}

output "consul_clients" {
  value = ["${aws_instance.consul_clients.*.private_ip}"]
}
