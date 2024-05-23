data "aws_s3_bucket" "bucket" {
  bucket = "shirel-instructions"
}

output "vido" {
  value = data.aws_s3_bucket.bucket.tags["activity"]
}
