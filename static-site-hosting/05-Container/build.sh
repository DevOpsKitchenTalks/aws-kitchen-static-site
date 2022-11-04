#!/bin/bash

set -e

echo $CR_PAT | docker login ghcr.io -u DovnarAlexander --password-stdin
docker build --platform=linux/amd64 --tag ghcr.io/devopskitchentalks/aws-kitchen-static-site:latest -f demo/05-Container/Dockerfile .
docker push ghcr.io/devopskitchentalks/aws-kitchen-static-site:latest
