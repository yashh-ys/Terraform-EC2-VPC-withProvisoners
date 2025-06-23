output "public-ip-address" {
    value = aws_instance.demo-app.public_ip
}