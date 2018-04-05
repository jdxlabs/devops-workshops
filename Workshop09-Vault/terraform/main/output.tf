output "bastion" {
  value = "${aws_instance.bastion.0.public_ip}"
}

output "vault_servers" {
  value = ["${aws_instance.vault_servers.*.private_ip}"]
}
