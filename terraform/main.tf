# ── Terraform Configuration ───────────────────────────────────
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # Remote state backend — stores terraform state in GCS bucket
  # We'll create this bucket manually first
  backend "gcs" {
    bucket = "employee-api-terraform-state"
    prefix = "terraform/state"
  }
}

# ── Provider Configuration ────────────────────────────────────
provider "google" {
  project = var.project_id
  region  = var.region
}

# ── Local Values ──────────────────────────────────────────────
locals {
  db_password = "EmployeeAPI@2024!"
  db_url      = "postgresql+pg8000://${var.db_user}:${local.db_password}@/${var.db_name}?unix_sock=/cloudsql/${var.project_id}:${var.region}:${var.app_name}-db/.s.PGSQL.5432"
}

# ── Module: VPC ───────────────────────────────────────────────
module "vpc" {
  source = "./modules/vpc"

  project_id  = var.project_id
  region      = var.region
  vpc_name    = "${var.app_name}-vpc"
  subnet_name = "${var.app_name}-subnet"
  subnet_cidr = var.subnet_cidr
}

# ── Module: Artifact Registry ─────────────────────────────────
module "artifact_registry" {
  source          = "./modules/artifact_registry"
  project_id      = var.project_id
  region          = var.region
  repository_name = var.app_name
}

# ── Module: IAM ───────────────────────────────────────────────
module "iam" {
  source = "./modules/iam"

  project_id = var.project_id
}

# ── Module: Secret Manager ────────────────────────────────────
module "secret_manager" {
  source = "./modules/secret_manager"

  project_id  = var.project_id
  environment = var.environment
  db_password = local.db_password
  db_url      = local.db_url

  depends_on = [module.cloud_sql]
}

# ── Module: Cloud SQL ─────────────────────────────────────────
module "cloud_sql" {
  source = "./modules/cloud_sql"

  project_id          = var.project_id
  region              = var.region
  environment         = var.environment
  instance_name       = "${var.app_name}-db"
  db_name             = var.db_name
  db_user             = var.db_user
  db_password         = local.db_password
  deletion_protection = false
}