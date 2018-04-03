output "bastion" {
  value = "${aws_instance.bastion.0.public_ip}"
}

output "es_masters" {
  value = ["${aws_instance.es_masters.*.private_ip}"]
}

output "es_workers" {
  value = ["${aws_instance.es_workers.*.private_ip}"]
}
