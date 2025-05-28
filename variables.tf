#variable for vpc cidr range
variable "vpc-id" {
    type = string
    default = "10.0.0.0/16"
}

#Give project a name
variable "project" {
    type = string
    default = "apache"
}

#Specify launch template AMI
variable "ami" {
    type = string
    default = "ami-0ef0975ebdd78b77b"
  
}