#!/bin/sh

DIR=$(dirname "$0")

docker-compose --env-file "$DIR/.env.monitoring" --project-name gsa --file "$DIR/compose.monitoring.yaml" down --rmi local --remove-orphans
