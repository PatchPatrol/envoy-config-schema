# Development Guidelines

## DevContainers

DevContainers provide isolated development environments, enhancing consistency and reproducibility across different development setups. The configuration for this project's DevContainer can be found in the `.devcontainer` directory.

For JetBrains IDE users, particularly those using IntelliJ IDEA, the following steps are necessary to establish a functional development environment using DevContainers:

1. Ensure the official DevContainers Plugin is installed (it is typically bundled with recent versions).
2. Initiate the DevContainer creation process from the IDE launcher, not during a remote session.
3. Access the "Find All Actions" menu using the appropriate shortcut for your operating system:
    - Windows/Linux: `Ctrl + Shift + A`
    - macOS: `Cmd + Shift + A`
      (Note: Your specific keybinding may vary)

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

Please note that the initial container may not align with the Dockerfile definition. You may find yourself in a container with a randomized name, operating as root, with your working directory set to `/IdeaProjects/<repo-name>`.

To properly configure your environment:
1. Source the `entrypoint.dev.sh` script located in the `.devcontainer` folder
2. This script will configure your PATH and verify the SSH agent setup
3. Follow the provided instructions to set your Git username and email within the container

## Development Workflow

This repository's primary objective is to generate JSON schemas for Envoy Proxy configurations based on its protobuf files.

The DevContainer setup includes a `build` directory where generated JSON schemas are stored. A Makefile in the repository root facilitates schema generation, which is automatically executed by the `postCreateCommand` in `devcontainer.json`:

```json
"postCreateCommand": "git config --global --add safe.directory /workspaces/envoy-config-schema && make install-deps && make generate-json-schema",
```

To manually generate the schema, execute:

```bash
make generate-json-schema
```

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