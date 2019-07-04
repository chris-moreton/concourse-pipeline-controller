#!/usr/bin/env bash
fly --target $CONCOURSE_NAME login --insecure --concourse-url $CONCOURSE_SERVER -u admin -p $CONCOURSE_ADMIN_PASSWORD
sudo fly --target $CONCOURSE_NAME sync

fly -t netsensia-concourse login -n golfingrecord --concourse-url $CONCOURSE_SERVER -u admin -p $CONCOURSE_ADMIN_PASSWORD
fly --target $CONCOURSE_NAME destroy-pipeline --non-interactive -p golfingrecord-mobile
fly --target $CONCOURSE_NAME destroy-pipeline --non-interactive -p golfingrecord-rhor

fly -t netsensia-concourse login -n directorzone --concourse-url $CONCOURSE_SERVER -u admin -p $CONCOURSE_ADMIN_PASSWORD
fly --target $CONCOURSE_NAME destroy-pipeline --non-interactive -p directorzone-api
fly --target $CONCOURSE_NAME destroy-pipeline --non-interactive -p directorzone-frontend


fly -t netsensia-concourse login -n main --concourse-url $CONCOURSE_SERVER -u admin -p $CONCOURSE_ADMIN_PASSWORD
fly --target $CONCOURSE_NAME destroy-pipeline --non-interactive -p pipeline-controller

fly -t netsensia-concourse login -n teps --concourse-url $CONCOURSE_SERVER -u admin -p $CONCOURSE_ADMIN_PASSWORD
fly --target $CONCOURSE_NAME destroy-pipeline --non-interactive -p teps-portal

./init-me.sh
