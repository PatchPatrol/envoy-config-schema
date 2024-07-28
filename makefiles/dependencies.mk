# makefiles/dependencies.mk

.PHONY: install-deps

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
	cd $(SCHEMA_GEN_DIR) && poetry install

.PHONY: dependencies-help
dependencies-help:
	@echo "Dependencies module commands:"
	@echo "  install-deps  - Install all dependencies"