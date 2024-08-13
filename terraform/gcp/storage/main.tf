provider "google" {
}

resource "google_storage_bucket" "bucket" {
  name     = var.bucket_name
  location = var.region
}

variable "region" {
  description = "The region in which to create the bucket"
  type        = string
  default     = "US"
}

variable "bucket_name" {
  description = "The name of the bucket to create"
  type        = string
}
