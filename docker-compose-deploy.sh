#!/bin/bash
docker login -u="${VRT_DOCKER_USER}" -p="${VRT_DOCKER_PASSWORD}" quay.io
export COMMIT_ID="${VRT_VERSION}" && docker-compose -f docker/docker-compose.yml build nginx-proxy
export COMMIT_ID="${VRT_VERSION}" && docker-compose -f docker/docker-compose.yml run api-service /go/bin/api migrate up
export COMMIT_ID="${VRT_VERSION}" && docker-compose -f docker/docker-compose.yml run api-service /go/bin/api seed
export COMMIT_ID="${VRT_VERSION}" && docker-compose -f docker/docker-compose.yml up -d