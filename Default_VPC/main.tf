#------ SSH KEYPAIR ------#
resource "aws_key_pair" "tf-keypair" {
    key_name   = "tf-provisioner"
    public_key = file("~/.ssh/id_rsa.pub")
}

#------ SECURITY GROUP ------#
resource "aws_security_group" "allow_ssh" {
    name        = "allow_ssh"
    description = "Allow ssh inbound traffic"

    #------ HTTP from VPC ------#
    ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }  
    #------ INBOUND RULE ------#
    ingress {
        description = "SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    #------ OUTBOUND RULE ------#
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "tf-sg"
    }
}

#------ EC2 INSTANCE ------#
resource "aws_instance" "tf-app" {
    ami                         = var.ami_id
    instance_type               = var.instance_type
    subnet_id                   = var.subnet_id
    key_name                    = aws_key_pair.tf-keypair.key_name
    vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
    associate_public_ip_address = true

    connection {
        type        = "ssh"
        user        = "ubuntu"
        private_key = file("~/.ssh/id_rsa")
        host        = aws_instance.tf-app.public_ip
    }

    #------ COPY FILE ------#
    provisioner "file" {
        source      = "app.py"
        destination = "/home/ubuntu/app.py" 
    }

    #------ EXECUTE COMMANDS INSIDE INSTANCE------#
    provisioner "remote-exec" {
        inline = [
            "sudo apt update",
            "sudo apt install -y python3-pip",
            "sudo apt install -y python3-flask",
            "cd /home/ubuntu",
            "sudo python3 app.py &",
        ]
    }

    tags = {
        Name = "tf-ec2"
    } 

}