# PostgreSQL with PostGIS and pgvector

A Docker-based PostgreSQL setup with PostGIS and pgvector extensions for geospatial and vector similarity search capabilities.

## 🏗️ Version Management

This repository allows specifying static versions for Docker images:

### Version Control Methods

1. **Static Version (Automatic)**: Modify `IMAGE_VERSION` in `.github/workflows/docker-image.yml`
2. **Manual Version**: Use the `docker-image-manual.yml` workflow to specify versions when running
3. **Configuration File**: See the `VERSION` file for current versions

### Changing the Image Version

To publish a new version:

1. **Static Method**: Edit `.github/workflows/docker-image.yml`:
   ```yaml
   env:
     IMAGE_VERSION: "0.1.0"  # Change this line
     POSTGRES_VERSION: "17.5"
   ```

2. **Manual Method**: Go to GitHub Actions → "Docker Image CI (Manual Version)" → "Run workflow"

## Repository Structure

```
├── Dockerfile             # PostgreSQL 17 with PostGIS and pgvector
├── docker-compose.yml     # Docker Compose configuration
├── init.sql              # Database initialization script
├── VERSION               # Version configuration
└── .github/
    └── workflows/
        ├── docker-image.yml        # Automatic build with static version
        └── docker-image-manual.yml # Manual build with version input
```

## Docker Hub Tags

The images are available with the following tags:

- `ruxwez/postgres:latest` - Latest build from the main branch
- `ruxwez/postgres:17.5-0.1.0` - Specific version (example)
- `ruxwez/postgres:[VERSION]` - Version specified in the workflow

### Current Version
- **Image**: `17.5-0.1.0`
- **PostgreSQL**: `17.5`
- **pgvector**: `v0.8.0`
- **PostGIS**: `3.x`

## Features

- **PostgreSQL**: Latest PostgreSQL versions
- **PostGIS**: Spatial database extender for PostgreSQL
- **pgvector**: Open-source vector similarity search for PostgreSQL
- **Docker Compose**: Easy deployment and management
- **Pre-configured**: Ready-to-use with extensions automatically enabled
- **Multi-architecture**: Supports AMD64 and ARM64 platforms

## Extensions Included

- **PostGIS 3**: Advanced geospatial functionality
- **pgvector v0.8.0**: Vector embeddings and similarity search
- **postgresql-contrib**: Additional PostgreSQL extensions

## Quick Start

### Prerequisites

- Docker and Docker Compose installed on your system

### Installation

1. Clone this repository:
```bash
git clone https://github.com/ruxwez/postgres.git
cd postgres
```

2. Start the PostgreSQL container:
```bash
docker-compose up -d
```

**Or use the pre-built image directly:**
```bash
docker run -d \
  --name postgres17 \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=1234 \
  -e POSTGRES_DB=postgres \
  -p 5432:5432 \
  ruxwez/postgres:latest
```

3. Connect to the database:
```bash
# Using psql
docker exec -it postgres17 psql -U postgres -d postgres

# Or using any PostgreSQL client
# Host: localhost
# Port: 5432
# Database: postgres
# Username: postgres
# Password: 1234
```

### Verification

Check that extensions are available:
```sql
-- Verify PostGIS extension
SELECT PostGIS_Version();

-- Verify pgvector extension
SELECT * FROM pg_extension WHERE extname = 'vector';

-- List all available extensions
\dx
```

## Configuration

### Environment Variables

The default configuration can be modified in `docker-compose.yml`:

```yaml
environment:
  POSTGRES_USER: postgres      # Database username
  POSTGRES_PASSWORD: 1234      # Database password
  POSTGRES_DB: postgres        # Default database name
```

### Custom Initialization

Add your SQL initialization scripts to the `init.sql` file or create additional `.sql` files in the project directory and mount them to `/docker-entrypoint-initdb.d/` in the container.

## Usage Examples

### PostGIS Example

```sql
-- Create a table with geometry column
CREATE TABLE locations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    geom GEOMETRY(POINT, 4326)
);

-- Insert some sample data
INSERT INTO locations (name, geom) VALUES 
    ('New York', ST_GeomFromText('POINT(-74.006 40.7128)', 4326)),
    ('London', ST_GeomFromText('POINT(-0.1276 51.5074)', 4326));

-- Find distance between points
SELECT 
    a.name, 
    b.name, 
    ST_Distance(a.geom::geography, b.geom::geography) / 1000 AS distance_km
FROM locations a, locations b 
WHERE a.id != b.id;
```

### pgvector Example

```sql
-- Create a table with vector column
CREATE TABLE embeddings (
    id SERIAL PRIMARY KEY,
    content TEXT,
    embedding vector(3)
);

-- Insert sample vectors
INSERT INTO embeddings (content, embedding) VALUES 
    ('document 1', '[1, 2, 3]'),
    ('document 2', '[4, 5, 6]'),
    ('document 3', '[1, 1, 1]');

-- Find similar vectors using cosine similarity
SELECT content, embedding <=> '[1, 2, 2]' AS distance
FROM embeddings
ORDER BY embedding <=> '[1, 2, 2]'
LIMIT 3;
```

## Docker Commands

### Start the container
```bash
docker-compose up -d
```

### Stop the container
```bash
docker-compose down
```

### View logs
```bash
docker-compose logs -f postgres
```

### Access the container shell
```bash
docker exec -it postgres17 /bin/bash
```

### Backup database
```bash
docker exec postgres17 pg_dump -U postgres postgres > backup.sql
```

### Restore database
```bash
docker exec -i postgres17 psql -U postgres postgres < backup.sql
```

## Data Persistence

Database data is persisted using Docker volumes. The `postgres_data` volume ensures your data survives container restarts and updates.

## Port Configuration

- **PostgreSQL**: 5432 (mapped to host port 5432)

## Building from Source

If you want to customize the Docker image:

```bash
docker build -t custom-postgres .
```

**With Docker Compose:**
```bash
docker-compose build
```

## Troubleshooting

### Connection Issues
- Ensure the container is running: `docker-compose ps`
- Check the logs: `docker-compose logs postgres`
- Verify port 5432 is not in use by another service

### Extension Issues
- Extensions are automatically installed during image build
- If extensions are missing, rebuild the image: `docker-compose build --no-cache`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test your changes
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Resources

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [PostGIS Documentation](https://postgis.net/documentation/)
- [pgvector Documentation](https://github.com/pgvector/pgvector)
- [Docker Documentation](https://docs.docker.com/)

## Author

Jose Garcia - [@ruxwez](https://github.com/ruxwez)