#!/usr/bin/env bash
fly --target $CONCOURSE_NAME login --insecure --concourse-url $CONCOURSE_SERVER -u admin -p $CONCOURSE_ADMIN_PASSWORD
sudo fly --target $CONCOURSE_NAME sync
fly --target $CONCOURSE_NAME destroy-pipeline -p directorzone-api
fly --target $CONCOURSE_NAME destroy-pipeline -p directorzone-frontend
fly --target $CONCOURSE_NAME destroy-pipeline -p pipeline-controller