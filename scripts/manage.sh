#!/bin/bash

# Use this to build and run your app with ease

show_help() {
    echo "Usage: ./manage.sh [command] [platform]"
    echo ""
    echo "Commands:"
    echo "  build <platform>    Build the docker image for a platform (web, android, linux, ios, windows)"
    echo "  run <platform>      Build and start the container (mostly for web/linux)"
    echo "  extract <platform>  Build and extract the artifact (APK/App) to ./build/output"
    echo "  stop                Stop all running containers"
    echo ""
    echo "Examples:"
    echo "  ./manage.sh build web"
    echo "  ./manage.sh run web"
    echo "  ./manage.sh extract android"
}

PLATFORM_ARG=""
if [ -n "$2" ]; then
    PLATFORM_ARG="--build-arg TARGET_OS=$2"
fi

case "$1" in
    "build")
        if [ -z "$2" ]; then echo "Please specify a platform!"; exit 1; fi
        echo "Building for $2, please wait..."
        docker build $PLATFORM_ARG -t zettelkasten-$2 .
        ;;
    "run")
        if [ -z "$2" ]; then echo "Please specify a platform!"; exit 1; fi
        if [ "$2" == "web" ]; then
            echo "Starting Web version on http://localhost:8080 ..."
            docker run -d -p 8080:80 --name zettelkasten-web-app zettelkasten-web
        elif [ "$2" == "linux" ]; then
            echo "Starting Linux version (needs X11)..."
            docker run -it --rm \
                -e DISPLAY=$DISPLAY \
                -v /tmp/.X11-unix:/tmp/.X11-unix \
                zettelkasten-linux
        else
            echo "Sorry, I can only 'run' web or linux easily!"
        fi
        ;;
    "extract")
        if [ -z "$2" ]; then echo "Please specify a platform!"; exit 1; fi
        echo "Extracting $2 artifacts to ./build/output..."
        mkdir -p ./build/output
        # Using BuildKit's --output feature for clean extraction
        # This requires Docker BuildKit
        DOCKER_BUILDKIT=1 docker build $PLATFORM_ARG --target $2-runtime --output type=local,dest=./build/output .
        echo "Done! Check Master's build/output folder!"
        ;;
    "stop")
        echo "Stopping containers..."
        docker stop zettelkasten-web-app
        docker rm zettelkasten-web-app
        ;;
    *)
        show_help
        ;;
esac
