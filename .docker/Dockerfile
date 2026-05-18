ARG POSTGRES_VERSION=17

FROM mirror.gcr.io/golang:1.26-alpine AS builder

WORKDIR /app

COPY go.mod go.sum* ./
RUN go mod download 2>/dev/null || true

COPY . .

RUN go build -o main .

FROM mirror.gcr.io/postgres:${POSTGRES_VERSION}

WORKDIR /opt/app

COPY --from=builder /app/main ./

RUN ./main && rm main
