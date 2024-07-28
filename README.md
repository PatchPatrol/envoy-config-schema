# Envoy Config Schema
> Maintained by [Patch Patrol](https://github.com/Patch-Patrol)

This repository provides JSON schemas for [Envoy Proxy](https://www.envoyproxy.io/) configuration files, enabling easier debugging and validation of `config.yaml` definitions.

## Overview

Envoy Proxy is a powerful and flexible edge and service proxy.
However, configuring it correctly can be challenging.

This project aims to simplify that process by providing JSON schemas that can be used for:

- IDE-based validation and autocompletion
- Pinpointing errors in configurations
- Ensuring consistency across Envoy setups

## Features

- JSON schemas generated from Envoy's proto configurations
- Versioned releases matching Envoy Proxy versions
- Easy integration with popular IDEs and validation tools

## Usage

### IDE Integration (VSCode Example)

1. Install the [YAML extension](https://github.com/redhat-developer/vscode-yaml) for VSCode.
2. Add the following to your VSCode settings:

```json
{
    "yaml.schemas": {
        "https://github.com/Patch-Patrol/envoy-config-schema/releases/download/v[VERSION]/v3_Bootstrap.json": "envoy-config.yaml"
    }
}
```

Replace `[VERSION]` with the desired Envoy version (e.g., `v1.21.0`).

### Command-line Validation

You can use tools like `jsonschema` to validate your Envoy configurations:

```bash
jsonschema -i your-config.yaml v3_Bootstrap.json
```

## Versioning

This repository follows the same versioning as the `envoyproxy/envoy` repository. Dependencies are aligned with those specified in [Envoy's repository_locations.bzl](https://github.com/envoyproxy/envoy/blob/main/api/bazel/repository_locations.bzl).

## Contributing

We welcome contributions! Please feel free to submit a Pull Request.

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Original work by [José Carlos Chávez](https://github.com/jcchavezs)
- [Envoy Proxy team](https://github.com/envoyproxy) for their excellent documentation and source code

---

For more information, bug reports, or feature requests, please [open an issue](https://github.com/Patch-Patrol/envoy-config-schema/issues).