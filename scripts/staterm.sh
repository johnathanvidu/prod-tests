#!/bin/bash

echo $TORQUE_TF_EXECUTABLE
echo $TORQUE_TF_MODULE_PATH

state=$TORQUE_TF_MODULE_PATH/terraform.tfstate

echo 'removing aws_s3_bucket.bucket from the state file'
$TORQUE_TF_EXECUTABLE state rm -state='$state' 'aws_s3_bucket.bucket'

$TORQUE_TF_EXECUTABLE apply -state='$state' -refresh-only
