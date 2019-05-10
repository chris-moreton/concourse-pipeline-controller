#!/usr/bin/env bash
fly --target netsensia-concourse login --insecure --concourse-url https://concourse.netsensia.com -u admin -p $CONCOURSE_NETSENSIA_PASSWORD
fly --target netsensia-concourse sync
fly --target netsensia-concourse set-pipeline --non-interactive -c pipeline.yml -p pipeline-initialiser
fly --target netsensia-concourse unpause-pipeline -p pipeline-initialiser
