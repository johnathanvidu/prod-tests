resource "aws_s3_bucket" "bucket_nksm81ch" {
  provider            = aws.eu_west_1
  bucket              = "eac-demo-vido"
  bucket_prefix       = null
  force_destroy       = null
  object_lock_enabled = false
  tags                = {}
  tags_all            = {}
}
