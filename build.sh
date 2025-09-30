#!/bin/bash

# Docker Build Script for rust-base-image
# Usage: ./build.sh [-s] [-p] [-t tag]
#   -s: Build with squash (requires experimental features enabled)
#   -p: Push to registry after successful build
#   -t: Specify custom tag (default: latest)

set -e

# Default values
SQUASH=false
PUSH=false
TAG="latest"
IMAGE_NAME="antvue/rust-base-image"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
usage() {
    echo "Usage: $0 [-s] [-p] [-t tag] [-i image] [-h]"
    echo ""
    echo "Options:"
    echo "  -s          Enable squash (requires Docker experimental features)"
    echo "  -p          Push to registry after successful build"
    echo "  -t tag      Specify tag (default: latest)"
    echo "  -i image    Specify image name (default: antvue/rust-base-image)"
    echo "  -h          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                              # Build with default settings"
    echo "  $0 -s                           # Build with squash"
    echo "  $0 -p                           # Build and push"
    echo "  $0 -s -p -t v1.0.0             # Build with squash, push with tag v1.0.0"
    echo "  $0 -i myuser/myimage -t v1.0.0  # Build with custom image name and tag"
    echo "  $0 -i localhost:5000/myimage    # Build for local registry"
}

# Parse command line arguments
while getopts "spt:i:h" opt; do
    case $opt in
        s)
            SQUASH=true
            print_info "Squash mode enabled"
            ;;
        p)
            PUSH=true
            print_info "Push mode enabled"
            ;;
        t)
            TAG="$OPTARG"
            print_info "Using tag: $TAG"
            ;;
        i)
            IMAGE_NAME="$OPTARG"
            print_info "Using image name: $IMAGE_NAME"
            ;;
        h)
            usage
            exit 0
            ;;
        \?)
            print_error "Invalid option: -$OPTARG"
            usage
            exit 1
            ;;
    esac
done

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    print_error "Docker is not running or not accessible"
    exit 1
fi

# Check if squash is enabled when requested
if [ "$SQUASH" = true ]; then
    if ! docker version --format '{{.Server.Experimental}}' 2>/dev/null | grep -q true; then
        print_warning "Docker experimental features not enabled. Squash may not work."
        print_info "To enable: Add '\"experimental\": true' to /etc/docker/daemon.json and restart Docker"
    fi
fi

# Build the image
print_info "Starting Docker build process..."
print_info "Image: $IMAGE_NAME:$TAG"
print_info "Squash: $SQUASH"
print_info "Push: $PUSH"

# Prepare build command
BUILD_CMD="docker build"

if [ "$SQUASH" = true ]; then
    BUILD_CMD="$BUILD_CMD --squash"
fi

BUILD_CMD="$BUILD_CMD -t $IMAGE_NAME:$TAG ."

print_info "Build command: $BUILD_CMD"

# Execute build
echo ""
print_info "Building Docker image..."
if eval $BUILD_CMD; then
    print_success "Docker build completed successfully!"
    
    # Show image info
    echo ""
    print_info "Image information:"
    docker images "$IMAGE_NAME:$TAG" --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}\t{{.CreatedAt}}"
else
    print_error "Docker build failed!"
    exit 1
fi

# Push if requested
if [ "$PUSH" = true ]; then
    echo ""
    print_info "Pushing image to registry..."
    
    # Check if user is logged in to Docker Hub
    if ! docker info 2>/dev/null | grep -q "Username:"; then
        print_warning "Not logged in to Docker registry"
        print_info "Please run 'docker login' first"
        exit 1
    fi
    
    if docker push "$IMAGE_NAME:$TAG"; then
        print_success "Image pushed successfully!"
        echo ""
        print_info "Image available at: https://hub.docker.com/r/$IMAGE_NAME"
        print_info "Pull command: docker pull $IMAGE_NAME:$TAG"
    else
        print_error "Failed to push image!"
        exit 1
    fi
fi

# Show final summary
echo ""
print_success "Build process completed!"
echo ""
print_info "Summary:"
echo "  - Image: $IMAGE_NAME:$TAG"
echo "  - Squash: $SQUASH"
echo "  - Push: $PUSH"

if [ "$PUSH" = false ]; then
    echo ""
    print_info "To push this image later, run:"
    echo "  docker push $IMAGE_NAME:$TAG"
fi

echo ""
print_info "To run the container:"
echo "  docker run --rm -it $IMAGE_NAME:$TAG sh"
echo "  docker run --rm -it $IMAGE_NAME:$TAG tokio-console --version"