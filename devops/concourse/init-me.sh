#!/usr/bin/env bash
fly --target netsensia-concourse login --insecure --concourse-url $CONCOURSE_SERVER -u admin -p $CONCOURSE_ADMIN_PASSWORD
fly --target netsensia-concourse sync
fly --target netsensia-concourse set-pipeline --non-interactive -c pipeline.yml -p pipeline-initialiser
fly --target netsensia-concourse unpause-pipeline -p pipeline-initialiser
