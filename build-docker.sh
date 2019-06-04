#!/usr/bin/env bash
docker build -t netsensia/pipelinefull:$1 -f devops/docker/Dockerfile_pipelinefull .
