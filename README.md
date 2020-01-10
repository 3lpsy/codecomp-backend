# CodeComp

CodeComp is a competive coding platform for developers and coders to test their skills in live competitions. It is currently in the early stages of development and following instructions are aimed at developers.

## About This Repo

This Repo contains the source code for the backend API

## Before Reading The Instructions

There is a docker-compose project in the works called codecomp-compose. This compose project encapsulates alot of this knowledge. **In general, it's better to leverage codecomp-compose than attempt to run the container in an isolated terminal session as there may be other services that are required for it to function appropriately.**

## Using The Docker Container

The Docker container contains a multi-stage build that first installs the dependencies, then builds the project. Whether the output of this build project is actually used depends on your command. The primary container pulls the executable from the builder image and places it in "/opt/app/codecomp-backend". The rest of the application (source) is stored in "/opt/go/src/codecomp-backend". In addition, golang and reflex is installed in the primary container by default. **These dependencies may be removed by default in later release and installed conditionally based on a build argument in order to save space**.

This means that you can do the following:

- Build and serve the binary as normal (statically with no changes)
- Sync the application source code and run the application with dynamic refreshes via reflex

## Building the Container

```
$ cd /path/to/codecomp-backend
$ docker build . -t white105/codecomp-backend:latest
```

## Mode 1: Running the Compiled Binary

This is the standard way to run the docker container and most similar to how it'll be run in production. To propagate changes, you have to rebuild the container.

```
$ docker run --rm -p 8080:8080 white105/codecomp-backend:latest
```

## Mode 2: Syncing the Source Code and Running via Reflex

This is the best way as of now to do development with golang and docker. It requires minimum rebuilds and the server automatically restarts when it detects changes. This build does not used the binary and instead uses the `go run` on the source code (via reflex).

To get syncing to work, it is important to mount the repo base at /opt/go/src/codecomp-backend.

```
$ docker run -v $(pwd):/opt/go/src/codecomp-backend -e SERVER=reflex -p 8080:8080 --rm white105/codecomp-backend:latest
```

### Environment Variables

```
SERVER:
This value can be set to "elf" (default) or "reflex". The "elf" server tells docker to execute the compiled binary at /opt/app/codecomp-backend. The "reflex" value instructs docker to leverage reflex to continually watch the source code at /opt/go/src/codecomp-backend for changes. When changes are detected, the app is restarted and run via 'go run'.

LISTEN_PORT:
This value tells the mux server which port to listen on. Inside the container, this the port you should forward to. For example, if LISTEN_PORT is 8080, but 8080 is in use on the host, you can forward the host's port 9090 to 8080 by using '-p 9090:8080'.

LISTEN_ADDR:
This is the bind address. It is either '0.0.0.0' or '127.0.0.1' (most likely). When running with docker, it should always be '0.0.0.0'. When running on the host (without docker), it is better to use '127.0.0.1' for security reasons.
```
