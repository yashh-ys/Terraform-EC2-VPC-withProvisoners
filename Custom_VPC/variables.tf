variable "cidr" {
    default = "10.0.0.0/16"
}

variable "ami_id" {
    type = string
    default = "ami-0f918f7e67a3323f0"
}

variable "instance_type" {
    type = string
    default = "t2.micro"
}
