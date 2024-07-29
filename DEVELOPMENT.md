# Development Guidelines

## DevContainers

DevContainers provide isolated development environments, enhancing consistency and reproducibility across different development setups. The configuration for this project's DevContainer can be found in the `.devcontainer` directory.

### Setting Up DevContainer

1. Ensure you have Docker installed on your system.
2. Clone this repository to your local machine.
3. Open the project in your IDE that supports DevContainers (e.g., VS Code, JetBrains IDEs).
4. When prompted, choose to reopen the project in a DevContainer.

For JetBrains IDE users, particularly those using IntelliJ IDEA:

1. Ensure the official DevContainers Plugin is installed (it is typically bundled with recent versions).
2. Initiate the DevContainer creation process from the IDE launcher, not during a remote session.
3. Access the "Find All Actions" menu using the appropriate shortcut for your operating system:
   - Windows/Linux: `Ctrl + Shift + A`
   - macOS: `Cmd + Shift + A`
     (Note: Your specific keybinding may vary)

### Remote Development Setup

For those intending to utilize a remote machine as their workstation, the following SSH configuration is required:

1. Edit your SSH configuration file:
   ```bash
   vim ~/.ssh/config
   ```

2. Add or modify the configuration for your remote machine:
   ```ssh
   Host your-remote-machine.tld
       Hostname <ip or domain>
       User <your remote username>
       IdentityFile <path to your private key>
       ForwardAgent yes
       AddKeysToAgent yes
   ```

3. Initialize the SSH agent and add your key:
   ```bash
   eval $(ssh-agent -s)
   ssh-add ~/.ssh/<your private key>
   ssh-add -l
   ssh your-remote-machine.tld
   echo "$SSH_AUTH_SOCK"
   ssh-add -L
   ```

4. Configure SSH in your IDE:
   - Access "Preferences > SSH Configurations"
   - Add a new configuration using the details from your `~/.ssh/config`
   - Select "OpenSSH and authentication agent" as the authentication method
   - Verify the connection

5. Create a Docker profile for the remote machine:
   - Access "Preferences > Docker"
   - Create a new profile linked to your SSH configuration
   - Map your local developer directory to the remote machine

6. Initiate the DevContainer:
   - From the IDE launcher, select "Dev Containers: New Dev Container"
   - Choose your newly created Docker profile
   - Provide the SSH Clone URL for the repository
   - Initiate the DevContainer creation process

### Development Environment

The DevContainer is set up with the following tools and configurations:

- Rocky Linux 9.3 as the base OS
- Python 3.11 with pyenv for version management
- Node.js LTS version with nvm for version management
- Go latest version
- Zsh with Oh My Zsh and Powerlevel10k theme
- Autojump for quick directory navigation
- Various development tools (git, make, gcc, etc.)

The development environment is set up automatically when the container starts. The `setup-dev-environment.sh` script handles the following:

- Sets up Zsh with Oh My Zsh and Powerlevel10k
- Configures Git with your GitHub username (if SSH agent forwarding is set up correctly)
- Sets up Python, Node.js, and Go environments
- Configures aliases and common tools

To manually run the setup script:

```bash
/home/developer/setup-dev-environment.sh
```

## Modular Makefiles

This project uses a modular Makefile system to organize and manage various development tasks. The main Makefile includes separate module files from the `makefiles` directory, each responsible for a specific aspect of the project.

### Main Makefile Structure

The main Makefile (`Makefile` in the root directory) sets up the modular structure:

```makefile
# Include other Makefile modules
define include_module
$(eval include $(1))
endef

$(foreach module,$(wildcard makefiles/*.mk),$(eval $(call include_module,$(module))))
```

This structure allows for easy addition of new modules and keeps the Makefile organized and maintainable.

### Available Modules

To see all available modules and get general help, run:

```bash
make help
```

This will display a list of available modules and instructions on how to get help for each module.

### Module-Specific Help

To get help for a specific module, use the `-help` suffix. For example:

- For dependencies: `make dependencies-help`
- For JSON schema generation: `make json_schema-help`
- For Poetry-related commands: `make poetry-help`
- For Zsh setup: `make zsh-help`

### Key Modules and Commands

1. Dependencies Module:
   - `make install-deps`: Install all dependencies

2. JSON Schema Module:
   - `make generate-json-schema`: Generate JSON schema for both v2 and v3
   - `make generate-json-schema-version VERSION=<v2|v3>`: Generate JSON schema for a specific version

3. Poetry Module:
   - `make generate-schema-for-version ENVOY_VERSION=<version>`: Generate schema for a specific Envoy version
   - `make check-new-release`: Check for new Envoy releases
   - `make seed-releases`: Seed releases for initial setup

4. Zsh Module:
   - `make devshell-zsh`: Set up a full Zsh environment
   - `make zsh-install`: Install Zsh and dependencies
   - `make zsh-configure`: Configure Zsh basics
   - `make zsh-plugins`: Install Zsh plugins
   - `make zsh-theme`: Set up Powerlevel10k theme
   - `make zsh-utils`: Install and configure additional utilities

This modular structure allows for easy management of different aspects of the project, from dependency installation to schema generation and environment setup.



## Development Workflow

This repository's primary objective is to generate JSON schemas for Envoy Proxy configurations based on its protobuf files.

The DevContainer setup includes a `build` directory where generated JSON schemas are stored. A Makefile in the repository root facilitates schema generation, which is automatically executed by the `postCreateCommand` in `devcontainer.json`:

```json
"postCreateCommand": "/home/developer/setup-dev-environment.sh",
```

To manually generate the schema, execute:

```bash
make generate-json-schema
```

## Customizing Your Environment

The development environment uses dotfiles for configuration. These are located in the `/home/developer/dotfiles` directory inside the container. You can modify these files to customize your environment:

- `.zshrc`: Zsh configuration
- `.bashrc`: Bash configuration
- `.shellrc`: Shared shell configuration (sourced by both Zsh and Bash)
- `.p10k.zsh`: Powerlevel10k theme configuration

## Future Enhancements

Several improvements are planned for this project:

1. Implement GitHub Actions to build the schema and upload it as artifacts
2. Develop a GitHub Page to present the schema in a user-friendly format
3. Host or link to the schema on the GitHub Page
4. Implement versioned directories for schema storage

Additionally, we aim to provide comprehensive documentation on utilizing the schema for Envoy configuration validation. This includes:

- Demonstrating how to validate `config.yaml` files against the schema in IntelliJ IDEA
- Offering guidance on schema validation across different Envoy versions
- Integrating linting capabilities in associated projects to ensure `config.yaml` validity

These enhancements will significantly improve the debugging process for Envoy configuration generation and validation across various projects and environments.