output "bastion" {
  value = "${aws_instance.bastion.0.public_ip}"
}

output "nomad_masters" {
  value = ["${aws_instance.nomad_masters.*.private_ip}"]
}

output "nomad_workers" {
  value = ["${aws_instance.nomad_workers.*.private_ip}"]
}
