.PHONY: run vendor build

# load dotenv & export
-include .env
export

ROOT = $(PWD)

# Install go modules dependencies
vendor:
	go mod vendor

run:
	@go run ./cmd/vmd/main.go

test:
	@go test -v -race -coverprofile=coverage.txt -covermode=atomic ./...

up:
	@docker-compose -f docker-compose.local.yaml up

down:
	@docker-compose -f docker-compose.local.yaml down -v

build:
	@CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o vmd ./cmd/vmd/...

# build for air
build-air:
	@go build -o ./tmp/app/engine cmd/vmd/main.go
	chmod +x ./tmp/app/engine

# if you use echo swagger
swagger:
	@echo Starting swagger generating
	swag init -g **/**/*.go

# generate db models if you use go-jet
dbgen-local:
	jet -source=mysql -host=localhost -port=3306 -user=user -password=1234 -dbname=test -path=./internal/gen

# make gen with env using passing argument(dev, prod)
# make db-gen DB_HOST=localhost DB_PORT=3306 DB_USER=user DB_PASSWORD=1234 DB_NAME=test
db-gen:
	# if arguments are not set, assert
	 if [ -z "$(DB_HOST)" ]; then \
	 	echo "DB_HOST is not set"; \
	 	exit 1; \
	 fi

	jet -source=mysql -host=$(DB_HOST) -port=$(DB_PORT) -user=$(DB_USER) -password=$(DB_PASSWORD) -dbname=$(DB_NAME) -path=./internal/gen

