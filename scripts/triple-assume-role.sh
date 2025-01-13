#!/bin/bash

echo $TORQUE_TF_MODULE_PATH

chmod +x $TORQUE_TF_MODULE_PATH/vido.sh

echo "export AWS_PROFILE=vido" >> ~/torque-envs.sh
