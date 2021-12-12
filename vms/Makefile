init-configs:
	docker config create caddy-conf ./Caddyfile
.PHONY: init-configs

init-network:
	docker network create --driver overlay gsa
.PHONY: init-network

init-all: init-network init-configs
.PHONY: init-all

prune-configs:
	docker config rm caddy-conf prometheus-conf caddymon-conf
.PHONY: prune-configs

prune-network:
	docker network rm gsa
.PHONY: prune-network

prune-all: prune-network prune-configs
.PHONY: prune-all

start-usersdb:
	docker service create \
		--constraint 'node.role == worker' \
		--constraint 'node.labels.category == dbs' \
		--endpoint-mode vip \
		--env MONGODB_PORT_NUMBER=20321 \
		--env-file dbs/.env.users \
		--health-cmd 'mongo --username $$MONGODB_USERNAME --password $$MONGODB_PASSWORD --host usersdb --port $$MONGODB_PORT_NUMBER $$MONGODB_DATABASE --authenticationDatabase=$$MONGODB_DATABASE --quiet --eval '\''db.runCommand("ping").ok'\''' \
		--health-interval 3s \
		--health-retries 2 \
		--health-start-period 10s \
		--health-timeout 2s \
		--hostname usersdb \
		--mode replicated \
		--mount type=volume,source=usersdb,destination=/bitnami/mongodb \
		--name usersdb \
		--network gsa \
		--replicas 1 \
		--replicas-max-per-node 1 \
		--restart-condition on-failure \
		--restart-delay 10s \
		--restart-max-attempts 10 \
		--restart-window 5s \
		docker.io/bitnami/mongodb:5.0
.PHONY: start-usersdb

start-coredb:
	docker service create \
		--constraint 'node.role == worker' \
		--constraint 'node.labels.category == dbs' \
		--endpoint-mode vip \
		--env-file dbs/.env.core \
		--health-cmd 'pg_isready -t 5 -d $$POSTGRESQL_DATABASE -h coredb -p 5432 -U $$POSTGRESQL_USERNAME' \
		--health-interval 5s \
		--health-retries 2 \
		--health-start-period 15s \
		--health-timeout 2s \
		--hostname coredb \
		--mode replicated \
		--mount type=volume,source=coredb,destination=/bitnami/postgresql \
		--name coredb \
		--network gsa \
		--replicas 1 \
		--replicas-max-per-node 1 \
		--restart-condition on-failure \
		--restart-delay 10s \
		--restart-max-attempts 4 \
		--restart-window 10s \
		docker.io/bitnami/postgresql:14
.PHONY: start-coredb

start-usersdbadmin:
	docker service create \
		--constraint 'node.role == worker' \
		--constraint 'node.labels.category == dba' \
		--endpoint-mode vip \
		--env ME_CONFIG_MONGODB_ENABLE_ADMIN=true \
		--env ME_CONFIG_OPTIONS_EDITORTHEME=base16-dark \
		--env ME_CONFIG_MONGODB_PORT=20321 \
		--env ME_CONFIG_MONGODB_SERVER=usersdb \
		--env VCAP_APP_HOST=usersdbadmin \
		--env-file dba/.env.users \
		--health-cmd 'wget --quiet --tries=1 --spider --auth-no-challenge --http-user=$$ME_CONFIG_BASICAUTH_USERNAME --http-password=$$ME_CONFIG_BASICAUTH_PASSWORD http://usersdbadmin:8081/db/admin' \
		--health-interval 5s \
		--health-retries 2 \
		--health-start-period 5s \
		--health-timeout 2s \
		--hostname usersdbadmin \
		--mode replicated \
		--name usersdbadmin \
		--network gsa \
		--replicas 1 \
		--replicas-max-per-node 1 \
		--restart-condition on-failure \
		--restart-delay 10s \
		--restart-max-attempts 10 \
		--restart-window 5s \
		docker.io/xeptore/mongo-express-wget:latest
.PHONY: start-usersdbadmin

start-coredbadmin:
	docker service create \
		--constraint 'node.role == worker' \
		--constraint 'node.labels.category == dba' \
		--endpoint-mode vip \
		--env PGADMIN_DISABLE_POSTFIX=true \
		--env PGADMIN_LISTEN_ADDRESS=coredbadmin \
		--env PGADMIN_LISTEN_PORT=8585 \
		--env-file dba/.env.core \
		--health-cmd 'wget --quiet --tries=1 --spider http://coredbadmin:$$PGADMIN_LISTEN_PORT/login' \
		--health-interval 5s \
		--health-retries 8 \
		--health-start-period 15s \
		--health-timeout 2s \
		--hostname coredbadmin \
		--mode replicated \
		--mount type=volume,source=coredbadmin_data,destination=/var/lib/pgadmin \
		--name coredbadmin \
		--network gsa \
		--replicas 1 \
		--replicas-max-per-node 1 \
		--restart-condition on-failure \
		--restart-delay 5s \
		--restart-max-attempts 10 \
		--restart-window 5s \
		docker.io/dpage/pgadmin4:6
.PHONY: start-coredbadmin

start-userssrv:
	docker service create \
		--constraint 'node.role == worker' \
		--constraint 'node.labels.category == app' \
		--endpoint-mode vip \
		--env SERVER_HOST=userssrv \
		--env SERVER_PORT=50050 \
		--env DATABASE_HOST=usersdb \
		--env DATABASE_PORT=20321 \
		--env DATABASE_USE_AUTH=true \
		--env-file apps/.env.userssrv \
		--hostname userssrv \
		--mode replicated \
		--name userssrv \
		--network gsa \
		--replicas 3 \
		--replicas-max-per-node 1 \
		--restart-condition on-failure \
		--restart-delay 5s \
		--restart-max-attempts 10 \
		--restart-window 5s \
		docker.io/xeptore/gsa-userssrv:3
.PHONY: start-userssrv

start-cache:
	docker service create \
		--constraint 'node.role == worker' \
		--constraint 'node.labels.category == cache' \
		--endpoint-mode vip \
		--env REDIS_PORT_NUMBER=7658 \
		--env-file apps/.env.cache \
		--health-cmd 'redis-cli -h cache -p $$REDIS_PORT_NUMBER ping' \
		--health-interval 5s \
		--health-retries 2 \
		--health-start-period 3s \
		--health-timeout 2s \
		--hostname cache \
		--mode replicated \
		--mount type=volume,source=redis_data,destination=/bitnami/redis/data \
		--name cache \
		--network gsa \
		--replicas 1 \
		--replicas-max-per-node 1 \
		--restart-condition on-failure \
		--restart-delay 5s \
		--restart-max-attempts 10 \
		--restart-window 5s \
		docker.io/bitnami/redis:6.2
.PHONY: start-cache

start-coresrv:
	docker service create \
		--constraint 'node.role == worker' \
		--constraint 'node.labels.category == app' \
		--endpoint-mode vip \
		--env ASPNETCORE_URLS=http://+:50052 \
		--env REDIS_HOST=cache \
		--env REDIS_PORT=7658 \
		--env POSTGRESQL_HOST=coredb \
		--env POSTGRESQL_PORT=5432 \
		--env USERS_SERVICE_ADDRESS=http://userssrv:50050 \
		--env-file apps/.env.coresrv \
		--health-cmd './Ping http://coresrv:50052' \
		--health-interval 5s \
		--health-retries 2 \
		--health-start-period 6s \
		--health-timeout 2s \
		--hostname coresrv \
		--mode replicated \
		--name coresrv \
		--network gsa \
		--replicas 3 \
		--replicas-max-per-node 1 \
		--restart-condition on-failure \
		--restart-delay 5s \
		--restart-max-attempts 10 \
		--restart-window 5s \
		docker.io/xeptore/gsa-coresrv:1
.PHONY: start-coresrv

run-prepper:
	docker service create \
		--constraint 'node.role == worker' \
		--constraint 'node.labels.category == app' \
		--endpoint-mode vip \
		--env CORE_SERVICE_ADDRESS=coresrv:50052 \
		--hostname prepper \
		--max-concurrent 1 \
		--mode replicated-job \
		--name prepper \
		--network gsa \
		--replicas 1 \
		--replicas-max-per-node 1 \
		--restart-condition on-failure \
		--restart-delay 5s \
		--restart-max-attempts 10 \
		--restart-window 5s \
		docker.io/xeptore/gsa-prepper:1
.PHONY: run-prepper

start-gateway:
	docker service create \
		--constraint 'node.role == worker' \
		--constraint 'node.labels.category == gateway' \
		--endpoint-mode vip \
		--env GATEWAY_USERSSRV_HOST=userssrv \
		--env GATEWAY_USERSSRV_PORT=50050 \
		--env GATEWAY_CORESRV_HOST=coresrv \
		--env GATEWAY_CORESRV_PORT=50052 \
		--env GATEWAY_LISTEN_HOST=gateway \
		--env GATEWAY_LISTEN_PORT=9292 \
		--health-cmd 'wget --quiet --tries=1 --spider http://gateway:9292/ping' \
		--health-interval 5s \
		--health-retries 2 \
		--health-start-period 6s \
		--health-timeout 2s \
		--hostname gateway \
		--mode replicated \
		--name gateway \
		--network gsa \
		--replicas 2 \
		--replicas-max-per-node 1 \
		--restart-condition on-failure \
		--restart-delay 5s \
		--restart-max-attempts 10 \
		--restart-window 5s \
		docker.io/xeptore/gsa-gateway:1
.PHONY: start-gateway

start-webserver:
	docker service create \
		--config source=caddy-conf,target=/etc/caddy/Caddyfile \
		--constraint 'node.role == worker' \
		--constraint 'node.labels.category == dmz' \
		--endpoint-mode vip \
		--env-file apps/.env.webserver \
		--health-cmd 'wget --quiet --tries=1 --spider http://webserver:8686' \
		--health-interval 5s \
		--health-retries 2 \
		--health-start-period 4s \
		--health-timeout 2s \
		--hostname webserver \
		--mode replicated \
		--mount type=volume,source=caddy_data,destination=/data \
		--mount type=volume,source=caddy_config,destination=/config \
		--name webserver \
		--network gsa \
		--publish published=8181,target=8181 \
		--publish published=8585,target=8585 \
		--publish published=9292,target=9292 \
		--replicas 3 \
		--replicas-max-per-node 1 \
		--restart-condition on-failure \
		--restart-delay 5s \
		--restart-max-attempts 10 \
		--restart-window 5s \
		docker.io/library/caddy:2
.PHONY: start-webserver


start-swarmvisualizer:
	docker service create \
		--constraint 'node.role == manager' \
		--endpoint-mode vip \
		--hostname swarmvisualizer \
		--mode replicated \
		--mount type=bind,source=/var/run/docker.sock,destination=/var/run/docker.sock,readonly=false \
		--name swarmvisualizer \
		--network gsa \
		--publish published=8383,target=8080 \
		--replicas 1 \
		--replicas-max-per-node 1 \
		--restart-condition on-failure \
		--restart-delay 5s \
		--restart-max-attempts 10 \
		--restart-window 5s \
		docker.io/dockersamples/visualizer:latest
.PHONY: start-swarmvisualizer


start-all: start-swarmvisualizer start-usersdb start-coredb start-usersdbadmin start-coredbadmin start-userssrv start-cache start-coresrv run-prepper start-gateway start-webserver
.PHONY: start-all
