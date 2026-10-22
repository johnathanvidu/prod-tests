resource "aws_s3_bucket_policy" "policy_pj5xsss" {
  provider = aws.eu_west_1
  bucket = "elasticbeanstalk-eu-west-1-046086677675"
  policy = "{\"Statement\":[{\"Action\":[\"s3:ListBucket\",\"s3:ListBucketVersions\",\"s3:GetObject\",\"s3:GetObjectVersion\"],\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::046086677675:role/InstanceProfilePowerUser\"},\"Resource\":[\"arn:aws:s3:::elasticbeanstalk-eu-west-1-046086677675\",\"arn:aws:s3:::elasticbeanstalk-eu-west-1-046086677675/resources/environments/*\"],\"Sid\":\"eb-af163bf3-d27b-4712-b795-d1e33e331ca4\"},{\"Action\":\"s3:DeleteBucket\",\"Effect\":\"Deny\",\"Principal\":{\"AWS\":\"*\"},\"Resource\":\"arn:aws:s3:::elasticbeanstalk-eu-west-1-046086677675\",\"Sid\":\"eb-58950a8c-feb6-11e2-89e0-0800277d041b\"}],\"Version\":\"2008-10-17\"}"
}
resource "aws_s3_bucket" "bucket_kbp14b0t" {
  provider = aws.eu_west_1
  bucket = "elasticbeanstalk-eu-west-1-046086677675"
  bucket_prefix = null
  force_destroy = null
  object_lock_enabled = false
  tags = {

  }
  tags_all = {

  }
}