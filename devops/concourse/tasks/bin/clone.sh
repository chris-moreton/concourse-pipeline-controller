#!/usr/bin/env bash
GITHUB_REPO=$1
DEPLOY_KEY_CREDHUB_LOCATION=$2
export CONCOURSE_NETSENSIA_PASSWORD=$3
export AWS_ACCESS_KEY_ID=$4
export AWS_SECRET_ACCESS_KEY=$5

fly --target netsensia-concourse login --insecure --concourse-url https://concourse.netsensia.com -u admin -p $CONCOURSE_NETSENSIA_PASSWORD
eval "$(control-tower info --iaas aws --env --region eu-west-2 netsensia-concourse)"

mkdir ~/.ssh
credhub get -q -n $DEPLOY_KEY_CREDHUB_LOCATION.private_key | sed -e 's/\(KEY-----\)\s/\1\n/g; s/\s\(-----END\)/\n\1/g' | sed -e '2s/\s\+/\n/g' > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
git clone $1 -key ~/.ssh/id_rsa

