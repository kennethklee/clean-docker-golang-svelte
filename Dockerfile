# Build Frontend
# ==============
FROM node:18.4.0-alpine3.16 AS nodebuilder
ARG VERSION=dev

WORKDIR /web
COPY web/package*.json ./
RUN npm install

COPY web/ .
# During build, use env variable `VERSION` for any places where the version is needed.
RUN npm run build

EXPOSE 3000
CMD npm run dev -- --host



# Build Backend
# =============
FROM golang:1.18.3-alpine AS gobuilder
ARG VERSION=dev

WORKDIR /app

# Install dependencies
RUN go install github.com/cosmtrek/air@v1.27.3

COPY app/ .
RUN apk add --no-cache gcc g++
RUN CGO_ENABLED=0 go build -v -ldflags "-s -w -X main.VERSION=$VERSION" -tags timetzdata -o app

EXPOSE 3000
HEALTHCHECK --start-period=5s --retries=2 CMD curl -If 0:3000
CMD ["/go/bin/air", "-c", "/app/air.toml"]



# Run App
# =======
# FROM debian:bookworm
# FROM alpine:3.16.0
FROM scratch
# Pick one of the three images above to run.

COPY --from=gobuilder /app/app .
COPY --from=nodebuilder /web/dist/ /static

EXPOSE 3000

CMD ["/app"]
