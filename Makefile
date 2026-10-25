PG_VERSION ?= 18
IMAGE ?= ruxwez/postgres

.PHONY: build test build-all

# Build one version for the local platform.
build:
	docker buildx bake pg-$(PG_VERSION) --load

# Build one version and run every extensions/*/test.sql against it.
test: build
	./tests/run.sh $(IMAGE):$(PG_VERSION)

# Build every version listed in docker-bake.hcl.
build-all:
	docker buildx bake --load
