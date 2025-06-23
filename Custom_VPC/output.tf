output "public-ip-address" {
    value = aws_instance.tf-app.public_ip
}