.PHONY: test

test:
	docker build -f .docker/Dockerfile.test -t postgres-extensor-test .
	-docker rmi postgres-extensor-test > /dev/null
