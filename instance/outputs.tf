output "Asha-Jyothi DNS Address" {
  value = "${aws_instance.aj_stack.public_ip}"
}

output "Asha-Jyothi Ip address" {
  value = "${aws_instance.aj_stack.public_dns}"
}