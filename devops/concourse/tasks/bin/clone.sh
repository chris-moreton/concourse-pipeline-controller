#!/bin bash
GITHUB_REPO=$1
DEPLOY_KEY_CREDHUB_LOCATION=$2

echo "Logging into Concourse..."
fly --target netsensia-concourse login --insecure --concourse-url https://concourse.netsensia.com -u admin -p $CONCOURSE_NETSENSIA_PASSWORD

echo "Logging into CredHub..."
eval "$(control-tower info --iaas aws --env --region eu-west-2 netsensia-concourse)"

echo "Getting deploy key from CredHub..."
mkdir ~/.ssh
credhub get -q -n $DEPLOY_KEY_CREDHUB_LOCATION -k private_key | sed -e 's/\(KEY-----\)\s/\1\n/g; s/\s\(-----END\)/\n\1/g' | sed -e '2s/\s\+/\n/g' > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
ssh -o "StrictHostKeyChecking=no" git@github.com
git clone  $1

