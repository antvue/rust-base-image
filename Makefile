# Makefile for rust-base-image Docker build

# Default values (can be overridden)
IMAGE_NAME ?= antvue/rust-base-image
TAG ?= latest

# Help target
.PHONY: help
help: ## Show this help message
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Build targets
.PHONY: build
build: ## Build the Docker image
	@echo "Building $(IMAGE_NAME):$(TAG)..."
	docker build -t $(IMAGE_NAME):$(TAG) .

.PHONY: build-squash
build-squash: ## Build the Docker image with squash
	@echo "Building $(IMAGE_NAME):$(TAG) with squash..."
	docker build --squash -t $(IMAGE_NAME):$(TAG) .

.PHONY: build-and-push
build-and-push: build push ## Build and push the Docker image

.PHONY: build-squash-and-push
build-squash-and-push: build-squash push ## Build with squash and push the Docker image

# Push target
.PHONY: push
push: ## Push the Docker image to registry
	@echo "Pushing $(IMAGE_NAME):$(TAG)..."
	docker push $(IMAGE_NAME):$(TAG)

# Test targets
.PHONY: test
test: ## Test the built image
	@echo "Testing $(IMAGE_NAME):$(TAG)..."
	docker run --rm $(IMAGE_NAME):$(TAG) tokio-console --version

.PHONY: shell
shell: ## Run interactive shell in the container
	docker run --rm -it $(IMAGE_NAME):$(TAG) sh

# Clean targets
.PHONY: clean
clean: ## Remove the local image
	docker rmi $(IMAGE_NAME):$(TAG) || true

.PHONY: clean-all
clean-all: ## Remove all versions of the image
	docker images $(IMAGE_NAME) -q | xargs -r docker rmi || true

# Info targets
.PHONY: info
info: ## Show image information
	@echo "Image: $(IMAGE_NAME):$(TAG)"
	@docker images $(IMAGE_NAME):$(TAG) --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}\t{{.CreatedAt}}" 2>/dev/null || echo "Image not found"

# Custom tag builds
.PHONY: tag
tag: ## Build with custom tag (use: make tag TAG=v1.0.0)
	@echo "Building $(IMAGE_NAME):$(TAG)..."
	docker build -t $(IMAGE_NAME):$(TAG) .

.PHONY: tag-squash
tag-squash: ## Build with custom tag and squash (use: make tag-squash TAG=v1.0.0)
	@echo "Building $(IMAGE_NAME):$(TAG) with squash..."
	docker build --squash -t $(IMAGE_NAME):$(TAG) .

# Development targets
.PHONY: dev
dev: build test ## Build and test (development workflow)

.PHONY: release
release: build-squash push test ## Build with squash, push, and test (release workflow)