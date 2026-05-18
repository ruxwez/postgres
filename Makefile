PG_VERSION ?= 18

.PHONY: test build

test:
	docker build -f .docker/Dockerfile.test -t postgres-extensor-test .
	-docker rmi postgres-extensor-test > /dev/null

build:
	docker build -f .docker/Dockerfile -t ruxwez/postgres:$(PG_VERSION) --build-arg POSTGRES_VERSION=$(PG_VERSION) .
