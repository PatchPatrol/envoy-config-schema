# makefiles/json_schema.mk

.PHONY: generate-json-schema generate-json-schema-version

generate-json-schema:
	$(MAKE) generate-json-schema-version VERSION=v2
	$(MAKE) generate-json-schema-version VERSION=v3

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

.PHONY: json_schema-help
json_schema-help:
	@echo "JSON Schema module commands:"
	@echo "  generate-json-schema              - Generate JSON schema for both v2 and v3"
	@echo "  generate-json-schema-version      - Generate JSON schema for a specific version"
	@echo "    Usage: make generate-json-schema-version VERSION=<v2|v3>"