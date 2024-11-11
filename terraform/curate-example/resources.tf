
resource "aws_s3_bucket" "bucket_axgh30c" {
  provider            = aws.us_east_1
  bucket              = "tf-backend-terragrunt2"
  bucket_prefix       = null
  force_destroy       = null
  object_lock_enabled = false
  tags                = {}
  tags_all            = {}
}
