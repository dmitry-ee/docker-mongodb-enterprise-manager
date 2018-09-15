#!make
CONTAINER_NAME		= mongodb-ops-manager
IMAGE_NAME				= mongodb-ops-manager
IMAGE_VERSION			= $(shell git describe --tags | sed 's/\([^-]*\)-.*/\1/')
DEFAULT_LOG_LINES = 20
define START_CMD
	-p 8080:8080 \
	--network="host" \
	-v "/etc/${CONTAINER_NAME}/cert:/etc/mongodb-mms" \
	-v "/etc/${CONTAINER_NAME}/conf:/opt/mongodb/mms/conf" \
	-v "/var/log/${CONTAINER_NAME}:/opt/mongodb/mms/logs" \
	docker.moscow.alfaintra.net/${IMAGE_NAME}:${IMAGE_VERSION}
endef
export START_CMD

all: build clean start-service logs

build:
	@./gradlew build $1>/dev/null
	@echo "BUILD SUCCESS"
version:
	@echo ${IMAGE_VERSION}
cmd:
	@echo docker run -it --name ${CONTAINER_NAME} ${START_CMD}

logs:
	@docker logs ${CONTAINER_NAME} --follow
logs-backup:
	@tail -n${DEFAULT_LOG_LINES} /var/log/${CONTAINER_NAME}/backup-daemon.log
logs-manager:
	@tail -n${DEFAULT_LOG_LINES} /var/log/${CONTAINER_NAME}/ops-manager.log

clean:
	- @docker rm -f ${CONTAINER_NAME}
full-clean: remove-logs remove-conf clean
cert-clean:
	@sudo rm -rf /etc/mongodb-ops-manager/cert

remove-logs:
	@sudo rm -rf /var/log/${CONTAINER_NAME}
remove-conf:
	@sudo rm -rf /etc/${CONTAINER_NAME}/conf

full-start: build full-clean start-service logs
start-service:
	@docker run -d --name ${CONTAINER_NAME} ${START_CMD}
start:
	@docker run -it --name ${CONTAINER_NAME} ${START_CMD}
start-bash:
	@docker run -it --name ${CONTAINER_NAME} ${START_CMD} bash
bash:
	@docker exec -it ${CONTAINER_NAME} bash
