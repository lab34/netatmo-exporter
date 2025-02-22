.PHONY: all test build-binary image all-images clean

GO ?= go
GO_OS ?= linux
GO_ARCH ?= amd64
GO_CMD := CGO_ENABLED=0 $(GO)
GIT_VERSION := $(shell git describe --tags --dirty)
VERSION := $(GIT_VERSION:v%=%)
GIT_COMMIT := $(shell git rev-parse HEAD)
GITHUB_REF ?= refs/heads/master
DOCKER_TAG != if [ "$(GITHUB_REF)" = "refs/heads/master" ]; then \
		echo "latest"; \
	else \
		echo "$(VERSION)"; \
	fi

all: test build-binary

test:
	$(GO_CMD) test -cover ./...

build-binary:
	GOOS=$(GO_OS) GOARCH=$(GO_ARCH) $(GO_CMD) build -tags netgo -ldflags "-w -X main.Version=$(VERSION) -X main.GitCommit=$(GIT_COMMIT)" -o netatmo-exporter .

image:
	podman build -t "lab34/netatmo-exporter:$(VERSION)" .

all-images:
	podman buildx build -t "lab34/netatmo-exporter:$(DOCKER_TAG)" --platform linux/amd64,linux/arm64 --push .

push: 
	podman build -t lab34/netatmo-exporter:latest .
 	podman push lab34/netatmo-exporter:latest

clean:
	rm -f netatmo-exporter
