#!/bin/bash

echo $TORQUE_TF_EXECUTABLE
echo $TORQUE_TF_MODULE_PATH

state=$TORQUE_TF_MODULE_PATH/terraform.tfstate

$TORQUE_TF_EXECUTABLE state rm 'aws_s3_bucket.bucket' -state=$state

$TORQUE_TF_EXECUTABLE apply -state=$state -refresh-only
