# do not use _ in default, use - 

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}

variable "db_instance_name" {}
variable "db_name" {}
variable "db_user" {}
variable "db_password" {}
