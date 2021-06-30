FROM golang as builder

WORKDIR /src/
COPY . .

ARG VET_FLAGS=""
RUN go vet "$VET_FLAGS"

ARG TEST_FLAGS=""
RUN go test "$TEST_FLAGS"

ARG LD_FLAGS='-linkmode external -w -extldflags "-static"'
ARG BUILD_FLAGS=""
RUN go build -ldflags "$LD_FLAGS" -o echo-server "$BUILD_FLAGS"


# ---
FROM alpine as runner

CMD ["/usr/code/echo-server"]

RUN apk add --update curl && rm -rf /var/cache/apk/*

HEALTHCHECK \
  --interval=30s \
  --timeout=30s \
  --start-period=5s \
  --retries=3 \
  CMD curl --head --fail localhost || exit 1

ARG UID=8080
ARG USER="docker-app"
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home /usr/code \
    --no-create-home \
    --uid "$UID" \
    "$USER"

ARG VERSION="0.1.0"
ARG ENVIRONMENT="dev"
ARG BRANCH="main"
ARG COMMIT_HASH="unknown"
ARG CREATED_DATE="unknown"

LABEL org.opencontainers.image.created="${CREATED_DATE}" \
    org.opencontainers.image.url="https://github.com/my-repo"  \
    org.opencontainers.image.source="https://github.com/my-repo/Dockerfile" \
    org.opencontainers.image.version="${VERSION}-${ENVIRONMENT}" \
    org.opencontainers.image.revision="${COMMIT_HASH}" \
    org.opencontainers.image.vendor="rainbowstack" \
    org.opencontainers.image.title="echo-server" \
    org.opencontainers.image.description="go echo server" \
    org.opencontainers.image.documentation="https://github.com/my-repo/README.md" \
    org.opencontainers.image.authors="nico braun" \
    org.opencontainers.image.licenses="(BSD-1-Clause)" \
    org.opencontainers.image.ref.name="${BRANCH}" \
    dev.rainbowstack.environment="${ENVIRONMENT}"

COPY --from=builder /src/echo-server /usr/code/
USER $USER