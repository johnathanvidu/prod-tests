#!/usr/bin/env bash
#SET_ENVIRONMENT_VARIABLES

# Stop Script on Error
set -e

# For Debugging (print env. variables into a file)  
printenv > /var/log/torque-vars-"$(basename "$BASH_SOURCE" .sh)".txt
 
echo "****************************************************************"
echo "Installing Docker"
echo "****************************************************************"
dnf install -y docker
systemctl enable --now docker

echo "****************************************************************"
echo "Installing Docker-Compose"
echo "****************************************************************"
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$(uname -m) -o /usr/libexec/docker/cli-plugins/docker-compose
cp /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose
chmod +x /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose

echo "****************************************************************"
echo "Installing QualiX"
echo "****************************************************************"
cd ~
curl -SL https://quali-prod-binaries.s3.amazonaws.com/deploy-qualix-docker-5.0.1.506.sh -o ./deploy-qualix-docker-5.0.1.506.sh
chmod +x deploy-qualix-docker-5.0.1.506.sh
./deploy-qualix-docker-5.0.1.506.sh

docker exec -u root qualix-guacamole touch /disableValidateLink