#!/usr/bin/env bash

docker-compose -f docker-compose.yaml up --detach
echo "success running docker-compose"
export TEST=testvalue