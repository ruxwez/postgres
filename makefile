test:
	@echo "Building test image with extensions..."
	docker build --build-arg POSTGRES_VERSION=18 --build-arg TEST_MODE=true -t postgres-test-local .
	@echo "Starting PostgreSQL container and running tests..."
	docker run --rm --name postgres-test-runner -e POSTGRES_PASSWORD=testmode postgres-test-local bash -c "docker-entrypoint.sh postgres & sleep 5 && until pg_isready -U postgres; do sleep 1; done && /usr/local/bin/installer --test-mode"

build:
	docker build -t ruxwez/postgres .
