
resource "aws_s3_bucket" "bucket_gy31l6oc" {
  provider            = aws.us_east_1
  bucket              = "tf-backend-terragrunt"
  bucket_prefix       = null
  force_destroy       = null
  object_lock_enabled = false
  tags                = {}
  tags_all            = {}
}
