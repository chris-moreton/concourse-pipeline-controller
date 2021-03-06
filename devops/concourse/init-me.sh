#!/usr/bin/env bash
fly --target $CONCOURSE_NAME login -n pipeline --insecure --concourse-url $CONCOURSE_SERVER -u admin -p $CONCOURSE_ADMIN_PASSWORD
sudo fly --target $CONCOURSE_NAME sync
fly --target $CONCOURSE_NAME set-pipeline --non-interactive -c pipeline.yml -p controller
fly --target $CONCOURSE_NAME unpause-pipeline -p controller
