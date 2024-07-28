# Makefile

# Variables
export BUILD_DIR := ./build
export BUILD_TMP_DIR := $(BUILD_DIR)/tmp
export SCHEMA_GEN_DIR := ./envoy-schema-generator

# Include other Makefile modules
define include_module
	$(eval include $(1))
endef

$(foreach module,$(wildcard makefiles/*.mk),$(eval $(call include_module,$(module))))

# Default target
.PHONY: all
all: help

# Help target
.PHONY: help
help:
	@echo "Envoy Config Schema Generator"
	@echo "============================="
	@echo ""
	@echo "Available modules:"
	@for file in makefiles/*.mk; do \
		module_name=$$(basename $$file .mk); \
		echo "  $$module_name"; \
	done
	@echo ""
	@echo "For more information on a specific module, run 'make <module>-help'"
	@echo "For example: 'make dependencies-help' or 'make json_schema-help'"

# List of all module help targets
MODULE_HELP_TARGETS := $(patsubst makefiles/%.mk,%-help,$(wildcard makefiles/*.mk))

.PHONY: $(MODULE_HELP_TARGETS)