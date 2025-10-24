ARG POSTGRES_VERSION=latest
ARG TEST_MODE=false

# Builder stage: compile the Rust binary
FROM rust:slim AS builder
WORKDIR /installer

# Copy dependency files first for better caching
COPY . .

RUN cargo build --release

# Final stage: only Postgres
FROM postgres:${POSTGRES_VERSION}
ARG TEST_MODE

# Copy the compiled binary
COPY --from=builder /installer/target/release/install-extensions /usr/local/bin/installer

# Run installer (all logic including cleanup is inside the binary)
RUN /usr/local/bin/installer

# If TEST_MODE is true, run tests
RUN if [ "${TEST_MODE}" = "false" ]; then rm /usr/local/bin/installer; fi

EXPOSE 5432
