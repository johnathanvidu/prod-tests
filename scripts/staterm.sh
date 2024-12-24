#!/bin/bash

echo $TORQUE_TF_EXECUTABLE
echo $TORQUE_TF_MODULE_PATH

state=$TORQUE_TF_MODULE_PATH/terraform.tfstate

echo 'removing aws_s3_bucket.bucket from the state file'
$TORQUE_TF_EXECUTABLE state rm -state=$state 'aws_s3_bucket.bucket'

$TORQUE_TF_EXECUTABLE -chdir=$TORQUE_TF_MODULE_PATH apply -auto-approve -var-file=$TORQUE_TF_MODULE_PATH/tf.vars.json -state=$state -refresh-only
