# Makefile for Envoy Config Schema Generator

# Variables
BUILD_DIR = ./build
BUILD_TMP_DIR = $(BUILD_DIR)/tmp
SCHEMA_GEN_DIR = ./envoy-schema-generator

# Define a function to run commands in the Poetry environment
define run_in_poetry_env
	@(cd $(SCHEMA_GEN_DIR) && poetry run $(1))
endef

# Phony targets
.PHONY: install-deps generate-json-schema generate-json-schema-version check-new-release seed-releases clean help

# Default target
all: install-deps generate-json-schema

# Install dependencies
install-deps:
	git submodule update --init --recursive
	# Pin submodules to specific commits
	cd ./libs/github.com/cncf/xds && git checkout d92e9ce0af512a73a3a126b32fa4920bee12e180
	cd ./libs/github.com/envoyproxy/protoc-gen-validate && git checkout 8c0f6372216272771488d63323787e86377aefe0
	cd ./libs/github.com/googleapis/googleapis && git checkout 82944da21578a53b74e547774cf62ed31a05b841
	cd ./libs/github.com/census-instrumentation/opencensus-proto && git checkout 4aa53e15cbf1a47bc9087e6cfdca214c1eea4e89
	cd ./libs/github.com/open-telemetry/opentelemetry-proto && git checkout b43e9b18b76abf3ee040164b55b9c355217151f3
	cd ./libs/github.com/prometheus/client_model && git checkout 147c58e9608a4f9628b53b6cc863325ca746f63a
	cd ./libs/github.com/envoyproxy/envoy && git checkout a9d72603c68da3a10a1c0d021d01c7877e6f2a30 #v1.21.0

	# Install Go tools
	go install github.com/chrusty/protoc-gen-jsonschema/cmd/protoc-gen-jsonschema@1.3.5
	go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.26
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.1

	# Install Python dependencies
	$(call run_in_poetry_env,poetry install)

# Generate JSON schema for both v2 and v3
generate-json-schema:
	$(MAKE) generate-json-schema-version VERSION=v2
	$(MAKE) generate-json-schema-version VERSION=v3

# Generate JSON schema for a specific version
generate-json-schema-version:
	@echo "Generating JSON schema for version $(VERSION)"
	@-rm -rf $(BUILD_TMP_DIR) && mkdir -p $(BUILD_TMP_DIR)
	@protoc --jsonschema_out=$(BUILD_TMP_DIR) \
		-I$(PWD)/libs/github.com/cncf/xds \
		-I$(PWD)/libs/github.com/cncf/udpa \
		-I$(PWD)/libs/github.com/envoyproxy/protoc-gen-validate \
		-I$(PWD)/libs/github.com/googleapis/googleapis \
		-I$(PWD)/libs/github.com/census-instrumentation/opencensus-proto/src \
		-I$(PWD)/libs/github.com/open-telemetry/opentelemetry-proto \
		-I$(PWD)/libs/github.com/prometheus/client_model \
		-I$(PWD)/libs/github.com/envoyproxy/envoy/api \
		$(PWD)/libs/github.com/envoyproxy/envoy/api/envoy/config/bootstrap/$(VERSION)/bootstrap.proto
	@ls $(BUILD_TMP_DIR) | xargs -I {} mv $(BUILD_TMP_DIR)/{} $(BUILD_DIR)/$(VERSION)_{}
	@rm -rf $(BUILD_TMP_DIR)
	@echo "JSON schema generation for version $(VERSION) completed"

# Generate schema for a specific Envoy version
generate-schema-for-version:
	@echo "Generating schema for Envoy version $(ENVOY_VERSION)"
	$(call run_in_poetry_env,python -m envoy_schema_generator.cli generate-schema --envoy-version $(ENVOY_VERSION))

# Check for new Envoy releases
check-new-release:
	@echo "Checking for new Envoy releases"
	$(call run_in_poetry_env,python -m envoy_schema_generator.cli check-new-release)

# Seed releases for initial setup
seed-releases:
	@echo "Seeding releases"
	$(call run_in_poetry_env,python -m envoy_schema_generator.cli seed-releases --num-releases 5)

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts"
	rm -rf $(BUILD_DIR)

# Help target
help:
	@echo "Available targets:"
	@echo "  install-deps              - Install all dependencies"
	@echo "  generate-json-schema      - Generate JSON schema for both v2 and v3"
	@echo "  generate-schema-for-version ENVOY_VERSION=<version> - Generate schema for a specific Envoy version"
	@echo "  check-new-release         - Check for new Envoy releases"
	@echo "  seed-releases             - Seed releases for initial setup"
	@echo "  clean                     - Clean build artifacts"
	@echo "  help                      - Show this help message"