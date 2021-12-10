init-network:
	docker network create --driver overlay gsa
.PHONY: init-network

init-volumes:
	docker volume create usersdb
	docker volume create coredb
	docker volume create coredbadmin_data
.PHONY: init-volumes

init-all: init-network init-volumes
.PHONY: init-all

prune-volumes:
	docker volume rm usersdb coredb coredbadmin_data
.PHONY: prune-volumes

prune-network:
	docker network rm prune gsa
.PHONY: prune-network

prune: prune-volumes prune-network
.PHONY: prune

start-usersdb:
	docker service create \
		--constraint 'node.role == worker' \
		--constraint 'node.labels.category == dbs' \
		--endpoint-mode vip \
		--env MONGODB_PORT_NUMBER=20321 \
		--env-file dbs/.env.users \
		--health-cmd 'mongo --username $MONGODB_USERNAME --password $MONGODB_PASSWORD --host usersdb --port $MONGODB_PORT_NUMBER $MONGODB_DATABASE --authenticationDatabase=$MONGODB_DATABASE --quiet --eval '\''db.runCommand("ping").ok'\''' \
		--health-interval 3s \
		--health-retries 2 \
		--health-start-period 20s \
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
		--health-cmd 'pg_isready -t 5 -d $POSTGRESQL_DATABASE -h coredb -p 5432 -U $POSTGRESQL_USERNAME' \
		--health-interval 5s \
		--health-retries 2 \
		--health-start-period 20s \
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
		--restart-window 20s \
		docker.io/bitnami/postgresql:14
.PHONY: start-coredb

start-dbs: start-usersdb start-coredb
.PHONY: start-dbs

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
		--health-cmd 'wget --quiet --tries=1 --spider --auth-no-challenge --http-user=$ME_CONFIG_BASICAUTH_USERNAME --http-password=$ME_CONFIG_BASICAUTH_PASSWORD http://usersdbadmin:8081/db/admin' \
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
		--health-cmd 'wget --quiet --tries=1 --spider http://coredbadmin:$PGADMIN_LISTEN_PORT/login' \
		--health-interval 5s \
		--health-retries 2 \
		--health-start-period 5s \
		--health-timeout 2s \
		--hostname coredbadmin \
		--mode replicated \
		--mount type=volume,source=coredbadmin_data,destination=/var/lib/pgadmin \
		--name coredbadmin \
		--network gsa \
		--replicas 1 \
		--replicas-max-per-node 1 \
		--restart-condition on-failure \
		--restart-delay 10s \
		--restart-max-attempts 10 \
		--restart-window 5s \
		docker.io/dpage/pgadmin4:6
.PHONY: start-coredbadmin

start-dbadmins: start-usersdbadmin start-coredbadmin
.PHONY: start-dbadmins
