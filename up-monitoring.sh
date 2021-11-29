#!/bin/sh

DIR=$(dirname "$0")

docker-compose --env-file "$DIR/.env.monitoring" --project-name gsa --file "$DIR/compose.monitoring.yaml" up --force-recreate --quiet-pull --wait --detach
