variable "project_id" {
  description = "GCP Project ID"
  type = string
}

variable "region" {
  description = "GCP Region"
  type = string
  default = "europe-west2"
}

variable "vpc_name" {
  description = "Name of the VPC network"
    type = string
    default = "employee-vpc"
}

variable "subnet_name" {
    description = "Name of the subnet"
    type = string
    default = "employee-subnet"
}

variable "subnet_cidr" {
  description = "CIDR range forthe subnet"
  type = string
  default = "10.0.1.0/24"
}