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
