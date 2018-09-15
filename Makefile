#!make
CONTAINER_NAME		= mongodb-ops-manager
CONTAINER_VERSION	= $(shell git describe --tags | sed \"s/\\([^-]*\\)-.*/\\1/\")

all:
	build clean start-service logs

build:
	./gradlew build

logs:
	docker logs $(CONTAINER_NAME) --follow
bash:
	docker exec -it $(CONTAINER_NAME) bash

clean:
	docker rm -f $(CONTAINER_NAME)

start-service:
	docker run -d --name $(CONTAINER_NAME) \
	  -p 8080:8080 \
	  --network="host" \
	  -v "/etc/mongodb-ops-manager/cert:/etc/mongodb-mms/" \
	  -v "/etc/mongodb-ops-manager/conf:/opt/mongodb/mms/conf" \
	  -v "/var/log/mongodb-ops-manager:/opt/mongodb/mms/logs" \
	  docker.moscow.alfaintra.net/mongodb-enterprise-manager:$(CONTAINER_VERSION)

start:
	docker run -it --name $(CONTAINER_NAME) \
		-p 8080:8080 \
		--network="host" \
		-v "/etc/mongodb-ops-manager/cert:/etc/mongodb-mms/" \
		-v "/etc/mongodb-ops-manager/conf:/opt/mongodb/mms/conf" \
		-v "/var/log/mongodb-ops-manager:/opt/mongodb/mms/logs" \
		docker.moscow.alfaintra.net/mongodb-enterprise-manager:$(CONTAINER_VERSION)

start-bash:
	docker run -it --name $(CONTAINER_NAME) \
		-p 8080:8080 \
		--network="host" \
		-v "/etc/mongodb-ops-manager/cert:/etc/mongodb-mms/" \
		-v "/etc/mongodb-ops-manager/conf:/opt/mongodb/mms/conf" \
		-v "/var/log/mongodb-ops-manager:/opt/mongodb/mms/logs" \
		docker.moscow.alfaintra.net/mongodb-enterprise-manager:$(CONTAINER_VERSION) bash
