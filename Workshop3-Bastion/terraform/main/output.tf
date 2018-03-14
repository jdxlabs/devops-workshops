output "bastion" {
  value = "${aws_instance.bastion.0.public_ip}"
}

output "nodejs_servers" {
  value = ["${aws_instance.nodejs_server.*.private_ip}"]
}
