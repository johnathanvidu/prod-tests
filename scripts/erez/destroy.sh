#!/bin/bash

# Download the mongosh binary
# TODO: bake mongosh binary into the image or find a maintained TF mongodb provider (I found one that was last updated 2 years ago)
echo "Hello! Destroying"
curl -s -f -L https://downloads.mongodb.com/compass/mongosh-2.2.12-linux-x64.tgz \
-o mongosh-2.2.6-linux-x64.tar.gz
tar xzf mongosh-2.2.6-linux-x64.tar.gz
chmod +x mongosh-2.2.6-linux-x64/bin/mongosh
mv mongosh-2.2.6-linux-x64/bin/mongosh /usr/local/bin/

wget --no-check-certificate https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem

echo "mongodb://$master_username:$master_password@$cluster_endpoint/admin"
# mongosh --tls --host $cluster_endpoint:27017 --username $master_username --password $master_password --tlsCAFile global-bundle.pem

mongosh --tls --tlsCAFile global-bundle.pem "mongodb://$master_username:$master_password@$cluster_endpoint/admin" \
--eval="db.dropUser(\"$app_user_username\")"

