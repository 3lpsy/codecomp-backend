### Builder Containeer ###

FROM golang:latest AS builder
# Copy the code from the host and compile it
RUN go get github.com/golang/dep/cmd/dep
WORKDIR $GOPATH/src/codecomp-backend

# Need to copy only necessary files to avoid cache busting
COPY conf $GOPATH/src/codecomp-backend/conf
COPY controllers $GOPATH/src/codecomp-backend/controllers
COPY models $GOPATH/src/codecomp-backend/models
COPY responses $GOPATH/src/codecomp-backend/responses
COPY routers $GOPATH/src/codecomp-backend/routers
COPY utils $GOPATH/src/codecomp-backend/utils
COPY Gopkg.lock $GOPATH/src/codecomp-backend/Gopkg.lock
COPY Gopkg.toml $GOPATH/src/codecomp-backend/Gopkg.toml
COPY server.go $GOPATH/src/codecomp-backend/server.go

RUN dep ensure -v
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GODEBUG=http2debug=2 go build  -o /codecomp-backend

### Main Container ###
FROM alpine:3.11

# ARG DEVELOPER_TOOLS=0

# GOX variables used for development version and
# ignored for non-development purposes.
ENV GOPATH /opt/go
ENV PATH /opt/go/bin:$PATH
# elf == compiled binary, other options are: "reflex"
ENV SERVER="elf"
ENV LISTEN_PORT="8080"
ENV LISTEN_ADDR="0.0.0.0"
# The 4 commands make directories for development with 
# go installed and allow for mounting repo/source as volume
RUN addgroup -S app && \
    adduser -S app -G app -D -h /opt/app && \
    mkdir /opt/app/data && \
    chown app:app /opt/app/data && \
    mkdir -p ${GOPATH}/src ${GOPATH}/bin && \
    chown -R app:app ${GOPATH} && \
    mkdir /opt/go/src/codecomp-backend && \
    chown -R app:app /opt/go/src/codecomp-backend

# Installing go defeats the purpose of the multi-stage build
# We will set a build argument to install go if building dev images
# RUN if [ "1" = "$DEVELOPER_TOOLS" ]; then apk add --update go git musl-dev gcc build-base; fi 
RUN  apk add --update go git musl-dev gcc build-base

COPY --from=builder /codecomp-backend /opt/app/codecomp-backend
COPY ./docker-run.sh /opt/docker-run.sh
RUN chmod +x /opt/docker-run.sh
COPY reflex.conf /reflex.conf

# Dropping privileges is a good practices inside containers
USER app

# As "app" user, install CompileDaemon to user's bin
# RUN if [ "1" = "$DEVELOPER_TOOLS" ]; then go get github.com/cespare/reflex; fi 
RUN go get github.com/cespare/reflex

EXPOSE 8080

ENTRYPOINT ["/opt/docker-run.sh"]