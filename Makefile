GOLANGCI_LINT_VERSION=1.32

.PHONY: default
default: generate run test lint format

.PHONT: generate
generate:
	go generate

.PHONY: run
run:
	go run . --version

.PHONY: test
test:
	go test ./...

.PHONY: lint
lint: ensure-golangci-lint
	./bin/golangci-lint run

.PHONY: format
format: ensure-gofumports
	find . -name \*.go | xargs ./bin/gofumports -local github.com/twpayne/chezmoi -w

.PHONY: ensure-tools
ensure-tools: ensure-gofumports ensure-golangci-lint

.PHONY: ensure-gofumports
ensure-gofumports:
	if [ ! -x bin/gofumports ] ; then \
		mkdir -p bin ; \
		( cd $$(mktemp -d) && go mod init tmp && GOBIN=$(shell pwd)/bin go get mvdan.cc/gofumpt/gofumports ) ; \
	fi

.PHONY: ensure-golangci-lint
ensure-golangci-lint:
	if [ ! -x bin/golangci-lint ] || ( ./bin/golangci-lint --version | grep -Fqv "version ${GOLANGCI_LINT_VERSION}" ) ; then \
		curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh -s -- v${GOLANGCI_LINT_VERSION} ; \
	fi

.PHONY: release
release:
	goreleaser release \
		--rm-dist \
		${GORELEASER_FLAGS}

.PHONY: test-release
test-release:
	goreleaser release \
		--rm-dist \
		--skip-publish \
		--snapshot \
		${GORELEASER_FLAGS}

.PHONY: update-devcontainer
update-devcontainer:
	rm -rf .devcontainer && mkdir .devcontainer && curl -sfL https://github.com/microsoft/vscode-dev-containers/archive/master.tar.gz | tar -xzf - -C .devcontainer --strip-components=4 vscode-dev-containers-master/containers/go/.devcontainer
