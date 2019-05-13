#!/bin bash

echo "AWS_ACCESS_KEY_ID=$1" > .env
echo "AWS_SECRET_ACCESS_KEY=$2" >> .env
echo "CONCOURSE_NETSENSIA_PASSWORD=$3" >> .env


