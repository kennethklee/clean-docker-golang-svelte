# docker-golang-svelte

Opinionated starter boilerplate for golang & svelte server. Any statically compiled UI can be used in place of svelte.

Getting Started
---------------

*Requirements*

- docker
- docker-compose

Start the stack in dev mode with `./dev.sh up`
Stop the stack with `./dev.sh stop`
Destroy the stack with `./dev.sh down`

Test the stack with `./dev.sh test` which runs `./dev.sh test-app` and `./dev.sh test-web`.

Run a production like environment with `./dev.sh staging` which will host the service on a random port. This will allow you to run integration tests on it. Or smoke test it in CI. Use `./dev.sh port` to discover the port.

For your own use, copy whatever you need into your project. Change for your own use. Here are some things I personally go through:

- `dev.sh` change PORT, and any extra helper stuff, like a `db` command
- `docker-compose.yml` add a `db` service, add environment variables
- `Dockerfile` rename output binary, change static output directory
- `app/air.toml` rename output binary here too

How it Works
------------

There's two modes: development and production modes.

### Production

In production mode, a single image is built to run the complete app in a single service.

Within the Dockerfile, `nodejs` and `golang` builders compile their output. Their output is combined into a `scratch` image, where the binary is placed in `/app` and the static UI files are placed in `/app/static`. The server then serves the API and static files.

### Development

In development mode, two services start; one `web` running `nodejs` image and the other `app` running `golang` image.

Each are independent. Hot-reload and testing will work in the `web` service. Likewise, live-reload and tests will work in the `app` service.

The `app` service will serve its API endpoints and then proxy the rest to the `web` service. This allow both to work in tandam.
