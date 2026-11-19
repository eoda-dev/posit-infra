#!/bin/sh
sudo apt install -y podman

podman run -d --name pg-test \
  --rm \
  -e POSTGRES_USER=testuser \
  -e POSTGRES_PASSWORD=testpass \
  -e POSTGRES_DB=testdb \
  -p 5432:5432 \
  docker.io/library/postgres:17

