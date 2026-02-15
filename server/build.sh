#!/bin/bash

docker build -t jb-gateway -f "$(dirname "$0")/../src/docker/Dockerfile" "$(dirname "$0")/../src/docker"
