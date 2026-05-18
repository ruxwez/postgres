ARG POSTGRES_VERSION=latest

# Builder stage: compile the Rust binary
FROM docker.io/rust:slim AS builder
WORKDIR /installer

# Copy dependency files first for better caching
COPY . .

RUN cargo build --release

# Final stage: only Postgres
FROM docker.io/postgres:${POSTGRES_VERSION}
ARG POSTGRES_VERSION

# Copy the compiled binary
COPY --from=builder /installer/target/release/install-extensions /usr/local/bin/installer

# Run installer (detecta la version automaticamente, incluye limpieza)
RUN /usr/local/bin/installer && rm /usr/local/bin/installer

EXPOSE 5432
