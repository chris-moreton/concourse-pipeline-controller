#!/bin bash

set -x

PIPELINE_NAME=$1
PIPELINE_CONFIG_PATH="devops/concourse/pipeline.yml"
PIPELINE_CONFIG_FILE="/tmp/$PIPELINE_NAME/$PIPELINE_CONFIG_PATH"

fly --target netsensia-concourse login --insecure --concourse-url https://concourse.netsensia.com -u admin -p $CONCOURSE_NETSENSIA_PASSWORD
fly --target netsensia-concourse sync
fly --target netsensia-concourse set-pipeline --non-interactive -c $PIPELINE_CONFIG_FILE -p $PIPELINE_NAME
fly --target netsensia-concourse unpause-pipeline -p $PIPELINE_NAME
fly --target netsensia-concourse trigger-job -j $PIPELINE_NAME/build
