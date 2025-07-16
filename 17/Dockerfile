# Use the official PostgreSQL 17 base image
FROM postgres:17.5

# Define the pgvector version to install
ARG PG_VECTOR_RELEASE="v0.8.0"

# Install necessary extensions and build tools
RUN apt-get update && apt-get install -y \
    postgresql-contrib \
    postgresql-17-postgis-3 \
    postgresql-17-postgis-3-scripts \
    git \
    build-essential \
    postgresql-server-dev-17 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install pgvector from source code
RUN git clone --branch ${PG_VECTOR_RELEASE} https://github.com/pgvector/pgvector.git /tmp/pgvector \
    && cd /tmp/pgvector \
    && make clean \
    && make OPTFLAGS="" \
    && make install \
    && cd / \
    && rm -rf /tmp/pgvector

# Clean up build packages to reduce image size
RUN apt-get update && apt-get remove -y \
    git \
    build-essential \
    postgresql-server-dev-17 \
    && apt-get autoremove -y \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy the optional initialization script
COPY init.sql /docker-entrypoint-initdb.d/

# Expose the default PostgreSQL port
EXPOSE 5432
