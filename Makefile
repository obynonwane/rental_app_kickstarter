SUBSCRIPTION_BINARY=subscriptionApp
MAIL_BINARY=mailApp
BROKER_BINARY=brokerApp
LISTENER_BINARY=listenerApp
LOGGING_BINARY=loggingApp
INVENTORY_BINARY=inventoryApp

# Images name to be pushed to docker hub
SUBSCRIPTION_IMAGE := biostech/rental-subscription-service:1.0.0
AUTHENTICATION_IMAGE := biostech/rental-authentication-service:1.0.0
MAIL_IMAGE := biostech/rental-mail-service:1.0.0
BROKER_IMAGE := biostech/rental-broker-service:1.0.0
LISTENER_IMAGE := biostech/rental-listener-service:1.0.0
LOGGING_IMAGE := biostech/rental-logging-service:1.0.0
INVENTORY_IMAGE := biostech/rental-inventory-service:1.0.0

# up: starts all containers in the background without forcing build
up: ## Start all containers in the background without forcing build
	@echo "Starting Docker images..."
	docker compose up -d
	@echo "Docker images started!"

# down: stop docker compose
down: ## Stop Docker Compose
	@echo "Stopping Docker Compose..."
	docker compose down
	@echo "Done!"

# up_build: stops docker compose (if running), builds all projects and starts docker compose
up_build:  build_mail_service build_broker_service build_listener_service build_logging_service build_inventory_service ## Stop, build, and start Docker Compose
	@echo "Stopping Docker images (if running...)"
	docker compose down
	@echo "Building (when required) and starting Docker images..."
	docker compose up --build
	@echo "Docker images built and started!"

# build_subscription_service: builds the subscription binary as a linux executable
build_subscription_service: ## Build the subscription service binary
	@echo "Building subscription service binary..."
	@cd ../subscription-service && env GOOS=linux CGO_ENABLED=0 go build -o ${SUBSCRIPTION_BINARY} ./cmd/api
	@echo "Done!"

# build_mail_service: builds the mail binary as a linux executable
build_mail_service: ## Build the mail service binary
	@echo "Building mail service binary..."
	@cd ../mail-service && env GOOS=linux CGO_ENABLED=0 go build -o ${MAIL_BINARY} ./cmd/api
	@echo "Done!"

# build_broker_service: builds the broker binary as a linux executable
build_broker_service: ## Build the broker service binary
	@echo "Building broker service binary..."
	@cd ../broker-service && env GOOS=linux CGO_ENABLED=0 go build -o ${BROKER_BINARY} ./cmd/api
	@echo "Done!"

# build_listener_service: builds the listener binary as a linux executable
build_listener_service: ## Build the listener service binary
	@echo "Building listener service binary..."
	@cd ../listener-service && env GOOS=linux CGO_ENABLED=0 go build -o ${LISTENER_BINARY} .
	@echo "Done!"

# build_logging_service: builds the logging binary as a linux executable
build_logging_service: ## Build the logging service binary
	@echo "Building logging service binary..."
	@cd ../logging-service && env GOOS=linux CGO_ENABLED=0 go build -o ${LOGGING_BINARY} ./cmd/api
	@echo "Done!"

# build_inventory_service: builds the inventory binary as a linux executable
build_inventory_service: ## Build the inventory service binary
	@echo "Building inventory service binary..."
	@cd ../inventory-service && env GOOS=linux CGO_ENABLED=0 go build -o ${INVENTORY_BINARY} ./cmd/api
	@echo "Done!"

# push_subscription: push subscription service to docker hub
build_push_subscription: ## Push the subscription service to Docker Hub
	cd ../subscription-service/ && docker build --no-cache -f Dockerfile -t $(SUBSCRIPTION_IMAGE) . && docker push $(SUBSCRIPTION_IMAGE)

# push_authentication_service: push authentication service to docker hub
build_push_authentication_service: ## Push the authentication service to Docker Hub
	cd ../auth-service/ && docker build --no-cache -f Dockerfile -t $(AUTHENTICATION_IMAGE) . && docker push $(AUTHENTICATION_IMAGE)

# push_mail_service: push mail service to docker hub
build_push_mail_service: ## Push the mail service to Docker Hub
	cd ../mail-service/ && docker build --no-cache -f Dockerfile -t $(MAIL_IMAGE) . && docker push $(MAIL_IMAGE)

# push_broker_service: push broker service to docker hub
build_push_broker_service: ## Push the broker service to Docker Hub
	cd ../broker-service/ && docker build --no-cache -f Dockerfile -t $(BROKER_IMAGE) . && docker push $(BROKER_IMAGE)

# push_listener_service: push listener service to docker hub
build_push_listener_service: ## Push the listener service to Docker Hub
	cd ../listener-service/ && docker build --no-cache -f Dockerfile -t $(LISTENER_IMAGE) . && docker push $(LISTENER_IMAGE)

# push_logging_service: push logging service to docker hub
build_push_logging_service: ## Push the logging service to Docker Hub
	cd ../logging-service/ && docker build --no-cache -f Dockerfile -t $(LOGGING_IMAGE) . && docker push $(LOGGING_IMAGE)

# push_inventory_service: push inventory service to docker hub
build_push_inventory_service: ## Push the inventory service to Docker Hub
	cd ../inventory-service/ && docker build --no-cache -f Dockerfile -t $(INVENTORY_IMAGE) . && docker push $(INVENTORY_IMAGE)

# build_push: push all images to docker hub
build_push: build_push_authentication_service build_push_subscription build_push_mail_service build_push_broker_service build_push_listener_service build_push_logging_service build_push_inventory_service ## Build and push all images to Docker Hub
	@echo "Building and pushing updated images"

# migrate_up_local: apply all migrations locally
migrate_up_local: ## Apply all migrations locally
	migrate -path ../db/migrations -database "postgresql://admin:password@localhost:5432/rental_solution_db?sslmode=disable" -verbose up

# migrate_down_local: rollback all migrations locally
migrate_down_local: ## Rollback all migrations locally
	migrate -path ../db/migrations -database "postgresql://admin:password@localhost:5432/rental_solution_db?sslmode=disable" -verbose down

# migrate_down_last_local: rollback the last migration locally
migrate_down_last_local: ## Rollback the last migration locally
	migrate -path ../db/migrations -database "postgresql://admin:password@localhost:5432/rental_solution_db?sslmode=disable" -verbose down 1

# dropdb: drop the database
dropdb: ## Drop the database
	docker exec -it postgres dropdb -U admin rental_solution_db

# createdb: create the database
createdb: ## Create the database
	docker exec -it postgres createdb --username=admin --owner=admin rental_solution_db

# migrate: create a new migration file e.g make migrate schema=<migration_name>
MIGRATE_CMD = migrate create -ext sql -dir ../db/migrations -seq
migrate: ## Create a new migration file e.g make migrate schema=<migration_name>
	@$(MIGRATE_CMD) $(schema)

# Variables
BRANCH ?= main

# make commit_name message="commit message"
# commit_broker: pushes broker service to github
commit_broker: ## commit_broker: pushes broker service to github
	@if [ "$(message)" = "" ]; then echo "Commit message required"; exit 1; fi
	@cd ../broker-service && git status
	@cd ../broker-service && git add .
	@cd ../broker-service && git commit -m "$(message)"
	@cd ../broker-service && git push origin $(BRANCH)

# commit_auth: pushes auth service to github
commit_auth: ## commit_auth: pushes auth service to github
	@if [ "$(message)" = "" ]; then echo "Commit message required"; exit 1; fi
	@cd ../auth-service && git status
	@cd ../auth-service && git add .
	@cd ../auth-service && git commit -m "$(message)"
	@cd ../auth-service && git push origin $(BRANCH)

# commit_listener: pushes listener service to github
commit_listener: ## commit_listener: pushes listener service to github
	@if [ "$(message)" = "" ]; then echo "Commit message required"; exit 1; fi
	@cd ../listener-service && git status
	@cd ../listener-service && git add .
	@cd ../listener-service && git commit -m "$(message)"
	@cd ../listener-service && git push origin $(BRANCH)

# commit_logging: pushes logging service to github
commit_logging: ## commit_logging: pushes logging service to github
	@if [ "$(message)" = "" ]; then echo "Commit message required"; exit 1; fi
	@cd ../logging-service && git status
	@cd ../logging-service && git add .
	@cd ../logging-service && git commit -m "$(message)"
	@cd ../logging-service && git push origin $(BRANCH)

# commit_mail: pushes mail service to github
commit_mail: ## commit_mail: pushes mail service to github
	@if [ "$(message)" = "" ]; then echo "Commit message required"; exit 1; fi
	@cd ../mail-service && git status
	@cd ../mail-service && git add .
	@cd ../mail-service && git commit -m "$(message)"
	@cd ../mail-service && git push origin $(BRANCH)

# commit_subscription: pushes subscription service to github
commit_subscription: ## commit_subscription: pushes subscription service to github
	@if [ "$(message)" = "" ]; then echo "Commit message required"; exit 1; fi
	@cd ../subscription-service && git status
	@cd ../subscription-service && git add .
	@cd ../subscription-service && git commit -m "$(message)"
	@cd ../subscription-service && git push origin $(BRANCH)

# commit_db: push project database sql to github
commit_db: ## commit_db: push project database sql to github
	@if [ "$(message)" = "" ]; then echo "Commit message required"; exit 1; fi
	@cd ../db && git status
	@cd ../db && git add .
	@cd ../db && git commit -m "$(message)"
	@cd ../db && git push origin $(BRANCH)

# commit_inventory: push inventory service to github
commit_inventory: ## commit_inventory: push inventory service to github
	@if [ "$(message)" = "" ]; then echo "Commit message required"; exit 1; fi
	@cd ../inventory-service && git status
	@cd ../inventory-service && git add .
	@cd ../inventory-service && git commit -m "$(message)"
	@cd ../inventory-service && git push origin $(BRANCH)


# commit_setup: push project setup to github
commit_setup: ## push project setup to github
	@if [ "$(message)" = "" ]; then echo "Commit message required"; exit 1; fi
	@git status
	@git add .
	@git commit -m "$(message)"
	@git push origin $(BRANCH)

# help: list all make commands
help: ## Show this help
	@echo "Available commands:"
	@awk 'BEGIN {FS = ":.*##"; printf "\n"} /^[a-zA-Z0-9_-]+:.*##/ { printf "  %-30s %s\n", $$1, $$2 } /^##@/ { printf "\n%s\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: migrate createdb dropdb migrate_down_last_local migrate_down_local migrate_up_local build_push build_push_logging_service \
		build_push_listener_service build_push_broker_service build_push_mail_service build_push_authentication_service build_push_subscription \
		build_logging_service build_listener_service build_broker_service build_mail_service build_subscription_service up_build down up help \
		commit_setup commit_subscription commit_mail commit_logging commit_listener commit_auth commit_broker commit_db build_push_inventory_service\
		build_inventory_service




#----------------------------------------Kubernetes commands-----------------------------------------------#
# encode a secret - base64: echo -n 'redis' | base64
# decode a secret - base64: echo 'cmVkaXMuCg==' | base64 --decode; echo
# decode a secret - kubectl: kubectl get secret secret -o jsonpath="{.data.REDIS_URL}" | base64 --decode




#------------------------------------Packages installed for react-native app-----------------------------------------#
#1. create reat-app - expo init my-new-project
#2. react-navigation   https://reactnavigation.org/docs/getting-started
#3. screen components get {route, navigation } props automatically
#4. icons -  https://docs.expo.dev/guides/icons/
# cd cmp/api go test -v .