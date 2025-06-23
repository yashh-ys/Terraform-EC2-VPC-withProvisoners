variable "ami_id" {
    type        = string
    default     = "ami-0f918f7e67a3323f0"
    description = "AWS insatnce AMI ID"
}

variable "instance_type" {
    type        = string
    default     = "t2.micro"
    description = "Instance type for AWS instance"
}

variable "subnet_id" {
    type        = string
    default     = "subnet-0498d4296c0dc482e"
    description = "Subnet ID for Instance"
}