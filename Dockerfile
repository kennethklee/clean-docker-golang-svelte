# Build Frontend
# ==============
FROM node:18.4.0-alpine3.16 AS nodebuilder
ARG VERSION=dev

WORKDIR /web
COPY web/package*.json ./
RUN npm install

COPY web/ .
RUN npm run build

EXPOSE 3001
CMD npm run dev -- --host



# Build Backend
# =============
FROM golang:1.18.3 AS gobuilder
ARG VERSION=dev

WORKDIR /app

# Install dependencies
RUN go install github.com/cosmtrek/air@v1.27.3

COPY app/ .
RUN go build -v -ldflags "-s -w -X main.VERSION=$VERSION" -tags timetzdata -o app

EXPOSE 3000
HEALTHCHECK --start-period=5s --retries=2 CMD curl -If 0:3000
CMD ["/go/bin/air", "-c", "/app/air.toml"]



# Run App
# =======
FROM scratch

WORKDIR /app

COPY --from=gobuilder /app/app /app/app
COPY --from=nodebuilder /web/dist/ /app/static

EXPOSE 3000

CMD ["/app/app"]
