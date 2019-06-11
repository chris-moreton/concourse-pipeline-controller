#!/usr/bin/env bash
fly --target $CONCOURSE_NAME login --insecure --concourse-url $CONCOURSE_SERVER -u admin -p $CONCOURSE_ADMIN_PASSWORD
sudo fly --target $CONCOURSE_NAME sync
fly --target $CONCOURSE_NAME destroy-pipeline --non-interactive -p golfingrecord-mobile
fly --target $CONCOURSE_NAME destroy-pipeline --non-interactive -p golfingrecord-rhor
fly --target $CONCOURSE_NAME destroy-pipeline --non-interactive -p directorzone-api
fly --target $CONCOURSE_NAME destroy-pipeline --non-interactive -p directorzone-frontend
fly --target $CONCOURSE_NAME destroy-pipeline --non-interactive -p pipeline-controller

./init-me.sh
