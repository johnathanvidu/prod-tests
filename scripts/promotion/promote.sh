 #!/bin/bash

# $TORQUE_TOKEN
# $AZURE_TOKEN
# $TARGET_ENVIRONMENT

pushd $TARGET_ENVIRONMENT # 

git checkout -b 'job-$(uuidgen)'
touch file.txt
git add .
git commit -am "test"
git push

popd