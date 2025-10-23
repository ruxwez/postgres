ARG POSTGRES_VERSION=17.5

# Builder stage: compile the Rust binary
FROM rust:slim AS builder
WORKDIR /installer

# Copy dependency files first for better caching
COPY . .

RUN cargo build --release

# Final stage: only Postgres
FROM postgres:${POSTGRES_VERSION}
ARG POSTGRES_VERSION

# Copy the compiled binary
COPY --from=builder /installer/target/release/install-extensions /usr/local/bin/installer

# Run installer (all logic including cleanup is inside the binary)
RUN /usr/local/bin/installer ${POSTGRES_VERSION} && \
    rm /usr/local/bin/installer

EXPOSE 5432
