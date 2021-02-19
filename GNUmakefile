# ----------
# variables
# ----------
DOCKER_COMPOSE		?= docker-compose
DOCKER_COMPOSE_CONFIG_DEV ?= $(CURDIR)/docker-compose_dev.yml
DATA_DIR ?= /data/signal/localstack /data/signal/postgres_database
LOCALSTACK_PORT?=45566
AWS_CLI = AWS_ACCESS_KEY_ID=xxxx AWS_SECRET_ACCESS_KEY=yyy aws --endpoint-url=http://127.0.0.1:$(LOCALSTACK_PORT) --region us-east-1 
BUILD=$(CURDIR)/build.sh
START=$(CURDIR)/start.sh
# Environments


# ----------
# commands
# ----------
ALL_CMDS = \
	start-env \
	stop-env \
	remove-env \
	init-env

.PHONY: $(ALL_CMDS)

build:
	$(BUILD)

start:
	$(START)

# start postgresql, redis, and localstack(s3 and sqs)
start-env:
	mkdir -p $(DATA_DIR) 
	LOCALSTACK_PORT=$(LOCALSTACK_PORT) $(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_CONFIG_DEV) up -d --remove-orphans --force-recreate
	# wait for localstash start
	@echo "====Run 'make init-service' to create sqs ===\n"
	

# stop postgresql, redis, and localstack(s3 and sqs)
stop-env:
	@LOCALSTACK_PORT=$(LOCALSTACK_PORT) $(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_CONFIG_DEV) stop

# remove postgresql, redis, and localstack(s3 and sqs)
remove-env:
	@LOCALSTACK_PORT=$(LOCALSTACK_PORT) $(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_CONFIG_DEV) down
	rm -rf $(DATA_DIR) 

init-env:
	$(AWS_CLI) sqs create-queue --queue-name signal-queue.fifo --attributes "FifoQueue=true"
	$(AWS_CLI) s3 mb s3://signal