terraform {
  backend "s3" {
    bucket = "eac-demo-vido"
    key    = "eac-demo/state"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_s3_bucket" "eac-demo-s3-bucket" {
  bucket  = "eac-demo-app"
}

resource "aws_instance" "eac-demo-app-vm" {
  ami           = "ami-01e93c66feed74d08"
  instance_type = "t2.micro"
}

resource "aws_cloudfront_distribution" "s3_distribution" {

  depends_on = [
    aws_s3_bucket.eac-demo-s3-bucket
  ]

  origin {
    domain_name = aws_s3_bucket.eac-demo-s3-bucket.bucket_regional_domain_name # "eac-demo-app.s3.eu-west-1.amazonaws.com"
    origin_id   = "my_first_origin"
  }
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "mypic"
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "my_first_origin"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
# Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "my_first_origin"
  forwarded_values {
      query_string = false
      headers      = ["Origin"]
  cookies {
        forward = "none"
      }
    }
  min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "allow-all"
  }
# Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id  = "my_first_origin"
  forwarded_values {
      query_string = false
  cookies {
        forward = "none"
      }
    }
  min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress             = true
    viewer_protocol_policy = "redirect-to-https"
  }
  price_class = "PriceClass_200"
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "IN"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_kms_key" "eac-demo-kms" {
  description = "secrets for the eac-demo app"
  policy      = file("kms_policy.json")
}

resource "aws_secretsmanager_secret" "eac-demo-secret" {
  name                    = "eac-demo-awesome-secret"
  recovery_window_in_days = 0
  kms_key_id              = aws_kms_key.eac-demo-kms.arn
}
