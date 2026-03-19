variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "employee-api-490420"
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "europe-west2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "app_name" {
  description = "Application name used for resource naming"
  type        = string
  default     = "employee-api"
}

variable "subnet_cidr" {
  description = "CIDR range for subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "employee_db"
}

variable "db_user" {
  description = "Database username"
  type        = string
  default     = "employee_user"
}