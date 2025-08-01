.PHONY: build start stop clean test help

# Default target
help:
	@echo "Available commands:"
	@echo "  build         - Build PostgreSQL image"
	@echo "  start         - Start PostgreSQL container"
	@echo "  stop          - Stop PostgreSQL container"
	@echo "  clean         - Remove all containers and volumes"
	@echo "  test          - Test the image"
	@echo "  help          - Show this help message"

# Build targets
build:
	docker compose build

# Start targets
start:
	docker compose up -d

# Stop targets
stop:
	docker compose down

# Clean target
clean:
	docker compose down -v
	docker system prune -f

# Test target
test:
	@echo "Testing image..."
	docker compose up -d
	sleep 10
	@echo "PostgreSQL Version:"
	docker exec postgres17 psql -U postgres -d postgres -c "SELECT version();"
	@echo "\nInstalled Extensions:"
	docker exec postgres17 psql -U postgres -d postgres -c "\dx"
	@echo "\nAvailable Extensions:"
	docker exec postgres17 psql -U postgres -d postgres -c "SELECT name, default_version, comment FROM pg_available_extensions ORDER BY name;"
	docker compose down
