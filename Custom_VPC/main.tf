#------ SSH KEYPAIR ------#
resource "aws_key_pair" "tf-keypair" {
    key_name   = "tf-provisioner"
    public_key = file("~/.ssh/id_rsa.pub")
}

#------ VPC CIDR ------#
resource "aws_vpc" "tf-vpc"{
    cidr_block = var.cidr
}

#------ AWS SUBNET ------#
resource "aws_subnet" "tf-sub" {
    vpc_id                  = aws_vpc.tf-vpc.id
    cidr_block              = "10.0.0.0/24"
    availability_zone       = "ap-south-1a"
    map_public_ip_on_launch = true
}

#------ IGW ------#
resource "aws_internet_gateway" "tf-igw" {
    vpc_id = aws_vpc.tf-vpc.id
}

#------ ROUTE TABLE ------#
resource "aws_route_table" "tf-RT" {
    vpc_id = aws_vpc.tf-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.tf-igw.id
    }
}

#------ ROUTE TABLE ASSOCIATION ------#
resource "aws_route_table_association" "tf-rta" {
    subnet_id      = aws_subnet.tf-sub.id
    route_table_id = aws_route_table.tf-RT.id
}

#------ SECURITY GROUP ------#
resource "aws_security_group" "tf-sg" {
    name        = "tf_SG"
    vpc_id      = aws_vpc.tf-vpc.id

    #------ HTTP FROM VPC ------#
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
    ami                    = var.ami_id
    instance_type          = var.instance_type
    subnet_id              = aws_subnet.tf-sub.id
    key_name               = aws_key_pair.tf-keypair.key_name
    vpc_security_group_ids = [aws_security_group.tf-sg.id]

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
        Name = "tf-app-ec2"
    } 

}