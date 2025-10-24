test:
	docker build -t postgres-testmode --build-arg TEST_MODE=true .
	docker run -e POSTGRES_PASSWORD=testmode postgres-testmode /usr/local/bin/installer --test-mode
	docker rmi postgres-testmode

build:
	docker build -t ruxwez/postgres .
