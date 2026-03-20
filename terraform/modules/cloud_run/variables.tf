variable "project_id" {
  description = "GCP Project ID"
  type        = string
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

variable "service_name" {
  description = "Cloud Run service name"
  type        = string
  default     = "employee-api"
}

variable "container_image" {
  description = "Docker image URL"
  type        = string
}

variable "cloud_run_sa_email" {
  description = "Service account email for Cloud Run"
  type        = string
}

variable "db_url_secret_id" {
  description = "Secret Manager secret ID for database URL"
  type        = string
}

variable "cloud_sql_connection" {
  description = "Cloud SQL instance connection name"
  type        = string
}

variable "min_instances" {
  description = "Minimum number of instances"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 3
}

variable "cpu" {
  description = "CPU limit"
  type        = string
  default     = "1"
}

variable "memory" {
  description = "Memory limit"
  type        = string
  default     = "512Mi"
}