#!/bin/bash

/app/1.5.5/terraform state rm 'aws_s3_bucket.bucket'

/app/1.5.5/terraform apply -refresh-only
