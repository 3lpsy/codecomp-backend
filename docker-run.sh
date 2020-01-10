#!/bin/sh

# enable errors
set -e;

# allow setting $SERVER to "cmd" to pass commands
# through entrypoint
if [ "cmd" != "$SERVER" ]; then 

    # reflex will watch the source code (/opt/go/src/codecomp-backend)
    # for changes and restart go when detected
    if [ "reflex" == "$SERVER" ]; then
        if [ ! -f /usr/bin/go ]; then 
            echo "Go binary not found at /usr/bin/go";
            echo "Did you build the image with DEVELOPER_TOOLS=1?"
            echo "Unable to run reflex server. Quiting";
            exit 1;
        fi
        cd /opt/go/src/codecomp-backend;
        echo "Getting Dependencies";
        # pull dependencies just in case
        go get;
        echo "Starting reflex server";
        exec reflex -c /reflex.conf

    # elf == Executable and Linkable Format
    # runs the compiled target from the first stage
    # image
    elif [ "elf" == "$SERVER" ]; then
        echo "Starting mux server";
        exec /opt/app/codecomp-backend;
    else    
        echo "Unkown \$SERVER Option: $SERVER";
        exit 1;
    fi

else
    cd /opt/go/src/codecomp-backend;
    exec "$@";
fi