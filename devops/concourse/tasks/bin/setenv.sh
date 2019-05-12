#!/usr/bin/env bash

export AWS_ACCESS_KEY_ID=$1
export AWS_SECRET_ACCESS_KEY=$2
export CONCOURSE_NETSENSIA_PASSWORD=$3

echo "Logging into Concourse..."
fly --target netsensia-concourse login --insecure --concourse-url https://concourse.netsensia.com -u admin -p $CONCOURSE_NETSENSIA_PASSWORD

echo "Logging into CredHub..."
eval "$(control-tower info --iaas aws --env --region eu-west-2 netsensia-concourse)"

