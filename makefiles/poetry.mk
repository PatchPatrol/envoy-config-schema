# makefiles/poetry.mk

define run_in_poetry_env
	@(cd $(SCHEMA_GEN_DIR) && poetry run $(1))
endef

.PHONY: generate-schema-for-version check-new-release seed-releases

generate-schema-for-version:
	@echo "Generating schema for Envoy version $(ENVOY_VERSION)"
	$(call run_in_poetry_env,python -m envoy_schema_generator.cli generate-schema --envoy-version $(ENVOY_VERSION))

check-new-release:
	@echo "Checking for new Envoy releases"
	$(call run_in_poetry_env,python -m envoy_schema_generator.cli check-new-release)

seed-releases:
	@echo "Seeding releases"
	$(call run_in_poetry_env,python -m envoy_schema_generator.cli seed-releases --num-releases 5)

.PHONY: poetry-help
poetry-help:
	@echo "Poetry module commands:"
	@echo "  generate-schema-for-version ENVOY_VERSION=<version> - Generate schema for a specific Envoy version"
	@echo "  check-new-release          - Check for new Envoy releases"
	@echo "  seed-releases              - Seed releases for initial setup"