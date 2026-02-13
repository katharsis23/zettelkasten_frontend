#!/bin/bash

# Flutter Multi-Platform Artifact Retrieval Script
# Extracts built artifacts from Docker containers

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="zettelkasten-flutter"
OUTPUT_DIR="../.artifacts"
CONTAINER_PREFIX="flutter-build"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Function to extract artifacts from container
extract_artifacts() {
    local platform=$1
    local container_name="${CONTAINER_PREFIX}-${platform}"
    local image_name="${IMAGE_NAME}-${platform}:latest"
    
    echo -e "${BLUE}Extracting $platform artifacts...${NC}"
    
    case $platform in
        "android")
            # Extract APK
            docker run --rm --name "$container_name" \
                -v "$(pwd)/$OUTPUT_DIR:/host-output" \
                "$image_name" \
                sh -c "cp /output/app-release.apk /host-output/todo-app-android.apk && \
                       echo 'APK extracted to $OUTPUT_DIR/todo-app-android.apk'"
            ;;
        "ios")
            # Extract iOS app bundle
            docker run --rm --name "$container_name" \
                -v "$(pwd)/$OUTPUT_DIR:/host-output" \
                "$image_name" \
                sh -c "cp -r /output/Runner.app /host-output/todo-app-ios.app && \
                       echo 'iOS app extracted to $OUTPUT_DIR/todo-app-ios.app'"
            ;;
        "linux")
            # Extract Linux executable
            docker run --rm --name "$container_name" \
                -v "$(pwd)/$OUTPUT_DIR:/host-output" \
                "$image_name" \
                sh -c "cp -r /app /host-output/todo-app-linux && \
                       echo 'Linux app extracted to $OUTPUT_DIR/todo-app-linux/'"
            ;;
        "windows")
            # Extract Windows executable
            docker run --rm --name "$container_name" \
                -v "$(pwd)/$OUTPUT_DIR:/host-output" \
                "$image_name" \
                sh -c "cp /app/todo_app.exe /host-output/todo-app-windows.exe && \
                       echo 'Windows executable extracted to $OUTPUT_DIR/todo-app-windows.exe'"
            ;;
        "web")
            # Extract web build
            docker run --rm --name "$container_name" \
                -v "$(pwd)/$OUTPUT_DIR:/host-output" \
                "$image_name" \
                sh -c "cp -r /usr/share/nginx/html /host-output/todo-app-web && \
                       echo 'Web build extracted to $OUTPUT_DIR/todo-app-web/'"
            ;;
        *)
            echo -e "${RED}Unsupported platform: $platform${NC}"
            return 1
            ;;
    esac
    
    echo -e "${GREEN}$platform artifacts extracted successfully!${NC}"
}

# Function to show available artifacts
show_artifacts() {
    echo -e "${YELLOW}Available artifacts in $OUTPUT_DIR:${NC}"
    if [ -d "$OUTPUT_DIR" ]; then
        ls -la "$OUTPUT_DIR" | grep -v "^total" | awk '{print "  " $9 " (" $5 " bytes)"}'
    else
        echo "  No artifacts found"
    fi
}

# Function to get platform info
get_platform_info() {
    local platform=$1
    local image_name="${IMAGE_NAME}-${platform}:latest"
    
    echo -e "${BLUE}Platform: $platform${NC}"
    
    if docker image inspect "$image_name" >/dev/null 2>&1; then
        echo -e "${GREEN}Image exists: $image_name${NC}"
        
        # Get image size
        local size=$(docker image inspect "$image_name" --format='{{.Size}}' | numfmt --to=iec)
        echo -e "${YELLOW}Size: $size${NC}"
        
        # Show build info if available
        docker run --rm "$image_name" cat build-info.txt 2>/dev/null || echo "No build info available"
    else
        echo -e "${RED}Image not found: $image_name${NC}"
        echo -e "${YELLOW}Build it first: ./build-multi-platform.sh --target-os $platform --load${NC}"
    fi
    echo ""
}

# Parse command line arguments
case "${1:-help}" in
    "android"|"ios"|"linux"|"windows"|"web")
        extract_artifacts "$1"
        show_artifacts
        ;;
    "all")
        echo -e "${YELLOW}Extracting all platform artifacts...${NC}"
        for platform in android ios linux windows web; do
            extract_artifacts "$platform"
        done
        show_artifacts
        ;;
    "list"|"ls")
        show_artifacts
        ;;
    "info")
        if [ -n "$2" ]; then
            get_platform_info "$2"
        else
            echo -e "${YELLOW}Platform information:${NC}"
            for platform in android ios linux windows web; do
                get_platform_info "$platform"
            done
        fi
        ;;
    "clean")
        echo -e "${YELLOW}Cleaning artifacts...${NC}"
        rm -rf "$OUTPUT_DIR"
        echo -e "${GREEN}Artifacts cleaned${NC}"
        ;;
    "help"|"-h"|"--help")
        echo "Flutter Multi-Platform Artifact Retrieval"
        echo ""
        echo "Usage: $0 [COMMAND] [PLATFORM]"
        echo ""
        echo "Commands:"
        echo "  android|ios|linux|windows|web  Extract artifacts for specific platform"
        echo "  all                            Extract all platform artifacts"
        echo "  list|ls                        List available artifacts"
        echo "  info [platform]                Show platform build information"
        echo "  clean                          Remove all artifacts"
        echo "  help|-h|--help                 Show this help"
        echo ""
        echo "Examples:"
        echo "  $0 android                    # Extract Android APK"
        echo "  $0 all                        # Extract all artifacts"
        echo "  $0 info android               # Show Android build info"
        echo "  $0 list                       # List extracted artifacts"
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac
