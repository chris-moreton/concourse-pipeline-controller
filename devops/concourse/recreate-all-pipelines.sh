#!/usr/bin/env bash
fly --target $CONCOURSE_NAME login --insecure --concourse-url $CONCOURSE_SERVER -u admin -p $CONCOURSE_ADMIN_PASSWORD
sudo fly --target $CONCOURSE_NAME sync

fly -t netsensia-concourse login -n golfingrecord --concourse-url $CONCOURSE_SERVER -u admin -p $CONCOURSE_ADMIN_PASSWORD
fly --target $CONCOURSE_NAME destroy-pipeline --non-interactive -p mobile
fly --target $CONCOURSE_NAME destroy-pipeline --non-interactive -p rhor
fly --target $CONCOURSE_NAME destroy-pipeline --non-interactive -p api

fly -t netsensia-concourse login -n directorzone --concourse-url $CONCOURSE_SERVER -u admin -p $CONCOURSE_ADMIN_PASSWORD
fly --target $CONCOURSE_NAME destroy-pipeline --non-interactive -p api
fly --target $CONCOURSE_NAME destroy-pipeline --non-interactive -p frontend
fly --target $CONCOURSE_NAME destroy-pipeline --non-interactive -p laravel
fly --target $CONCOURSE_NAME destroy-pipeline --non-interactive -p controller

fly -t netsensia-concourse login -n pipeline --concourse-url $CONCOURSE_SERVER -u admin -p $CONCOURSE_ADMIN_PASSWORD
fly --target $CONCOURSE_NAME destroy-pipeline --non-interactive -p controller

fly -t netsensia-concourse login -n rivalchess --concourse-url $CONCOURSE_SERVER -u admin -p $CONCOURSE_ADMIN_PASSWORD
fly --target $CONCOURSE_NAME destroy-pipeline --non-interactive -p engine

fly -t netsensia-concourse login -n arrvd --concourse-url $CONCOURSE_SERVER -u admin -p $CONCOURSE_ADMIN_PASSWORD
fly --target $CONCOURSE_NAME destroy-pipeline --non-interactive -p api

./init-me.sh
