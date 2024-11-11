
resource "aws_s3_bucket" "bucket_axgh30c" {
  provider            = aws.eu_west_1
  bucket              = "tf-backend-terragrunt2"
  bucket_prefix       = null
  force_destroy       = null
  object_lock_enabled = false
  tags                = {}
  tags_all            = {}
}
