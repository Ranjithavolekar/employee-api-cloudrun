variable "repository_name" {
  description = "Name of the Artifact Registry repository"
  type        = string
  default     = "employee-api"
}
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "europe-west2"
}