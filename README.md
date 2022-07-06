# docker-golang-svelte

This is an example of a dockerized golang & svelte application. The result is a tiny `scratch` docker image. Both golang app and svelte app are testable during development. Live/Hot reload also work.

*NOTE: Any statically compiled UI can be used in place of svelte. Any server that can reverse proxy can be used in place of golang.*

The `./app` directory contains the golang server. The `./web` directory contains the nodejs server with svelte. Henceforth, they will be considered `app` layer and `web` layer.

A single `Dockerfile` binds them together.


Quick Start
-----------

To run this example, you'll need the following:

*Requirements*

- docker
- docker-compose
- bash

`./dev.sh` is your task runner. As such:

- Start the stack in dev mode with `./dev.sh up`
- Stop the stack with `./dev.sh stop`
- Destroy the stack with `./dev.sh down`
- Test the stack with `./dev.sh test`

Run a production-like environment with `./dev.sh staging`. Run integration tests or smoke tests on it. Use `./dev.sh port` to discover the port.

For more commands: `./dev.sh`

Usage (and reproduction steps)
------------------------------

The core of the structure is the root files. They control how the whole application is assembled.

Here are the steps to reproduce the structure for your own project:

1. Copy `dev.sh`. Change PORT, add extra helper commands (like `db`), add loading test fixtures in `init` section. This is application task runner.
2. Copy all `docker-compose.yml` related files, rename images, add environment variables and other services (like `db`).
3. Copy `Dockerfile` and rename output binary.
4. Create `./app` directory and copy `app/air.toml`. Rename output binary here too.
5. Create the app: `go mod init <name>` in the `./app` directory.
6. Create a `./app/.gitignore` file with `tmp/` and output binary name.
7. Copy over the [reverse proxy part](./app/main.go). Structure your app how you like it.
8. Create the web app:`npm init vite@latest`, name it `web`, select `svelte`.
9. Test it out with `./dev.sh init` to run in development mode.

As you work on each layer, the live-reload or hot-reload will recompile for you. You can manually rebuild with `./dev.sh up --build`. Test with `./dev.sh test`.

When your app is ready to deploy, build the final docker image: `IMAGE=username/project:1.0.0 ./dev.sh build`.


How it Works
------------

There's two modes: development and production modes.

### Production Mode

Production mode is what you use to deploy a production-ready app.

The golang app will need to serve the `/static` directory when it detects any non-development mode.

In production mode, a single `scratch` image is built to run the complete app within a single service. It's built with multi-stage builders, `nodebuilder` and `gobuilder`. Their output is combined into a `scratch` image, where the binary is placed in `/app` and the static UI files are placed in `/static`.

### Development Mode

In development mode, two services start; one `web` running `nodejs` image and the other `app` running `golang` image.

The golang app will need to erve its API endpoints and reverse proxy to the `web` layer when it detects development mode.

Each layer is independent and testable: `./dev.sh test` to test both layers.

### app layer

Code changes trigger live-reload thanks to air. Run tests with `./dev.sh test-app`.

#### web layer

Code changes will trigger hot-reload thanks to vite. Run tests with `./dev.sh test-web`.
