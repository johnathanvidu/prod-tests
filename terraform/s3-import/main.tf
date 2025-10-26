# Use the random provider to ensure the bucket name is globally unique
resource "random_pet" "bucket_name" {
  prefix    = "tf-simple-module"
  length    = 2
  separator = "-"
}

# The AWS S3 Bucket Resource to be created
resource "aws_s3_bucket" "example_bucket" {
  # Concatenate a random ID to ensure global uniqueness (S3 requirement)
  bucket = random_pet.bucket_name.id
  
  # Best practice: Block all public access by default
  tags = {
    Name        = "Simple-Managed-S3-Bucket"
    Environment = "Dev"
  }
}

# Apply default S3 best practices to the newly created bucket
resource "aws_s3_bucket_public_access_block" "example_bucket" {
  bucket = aws_s3_bucket.example_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Output
