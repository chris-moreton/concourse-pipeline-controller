#!/usr/bin/env bash
GITHUB_REPO=$1
DEPLOY_KEY_CREDHUB_LOCATION=$2

mkdir ~/.ssh
echo "credhub get -q -n $DEPLOY_KEY_CREDHUB_LOCATION"
credhub get -q -n $DEPLOY_KEY_CREDHUB_LOCATION -k private_key | sed -e 's/\(KEY-----\)\s/\1\n/g; s/\s\(-----END\)/\n\1/g' | sed -e '2s/\s\+/\n/g' > ~/.ssh/deploy_key_tmp
chmod 600 ~/.ssh/deploy_key_tmp
ssh-add ~/.ssh/deploy_key_tmp
git clone $1

