#!/bin/bash
set -e

echo "Starting setup-dev-environment.sh"

echo "Setting up development environment..."

# Ensure correct ownership of the IntelliJ Projects directory
if [ -d "/IdeaProjects" ]; then
    sudo chown -R developer:developer /IdeaProjects
    echo "Ownership of /IdeaProjects changed to developer:developer"
fi


# Ensure the dotfiles directory exists and has correct ownership
sudo mkdir -p /home/developer/dotfiles
sudo chown -R developer:developer /home/developer/dotfiles

# Install Antidote if not already installed
if [ ! -d "${HOME}/.antidote" ]; then
    git clone --depth=1 https://github.com/mattmc3/antidote.git ${HOME}/.antidote
fi

# Install additional tools (e.g., zoxide)
curl -sS https://webinstall.dev/zoxide | bash

# Set Zsh as the default shell
if ! grep -q "zoxide init zsh" ~/.zshrc; then
    echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc
fi

# Change default shell to Zsh
if [ "$SHELL" != "/bin/zsh" ]; then
    sudo chsh -s /bin/zsh developer
    echo "Default shell changed to Zsh. Please log out and log back in for the change to take effect."
fi

# Function to safely find executables
find_executable() {
    if command -v which >/dev/null 2>&1; then
        which "$1" 2>/dev/null || echo "$1 not found"
    else
        command -v "$1" 2>/dev/null || echo "$1 not found"
    fi
}

# Debugging information
echo "Current user: $(whoami)"
echo "Current directory: $(pwd)"
echo "Current PATH: $PATH"
echo "Current SHELL: $SHELL"
echo "ZSH location: $(find_executable zsh)"
echo "BASH location: $(find_executable bash)"

# Determine the actual mount point
if [ -d "/IdeaProjects" ]; then
    ACTUAL_MOUNT=$(find /IdeaProjects -maxdepth 1 -type d | tail -n 1)
elif [ -d "/workspaces" ]; then
    ACTUAL_MOUNT="/workspaces/envoy-config-schema"
else
    ACTUAL_MOUNT="/tmp/dummy-project-root"
    mkdir -p "$ACTUAL_MOUNT"
    echo "Created dummy project root at $ACTUAL_MOUNT"
fi

# Create the desired directory structure
mkdir -p /home/developer/Developer/src

# Create a symbolic link
ln -sfn "$ACTUAL_MOUNT" /home/developer/Developer/src/envoy-config-schema

# Set the PROJECT_ROOT
export PROJECT_ROOT="/home/developer/Developer/src/envoy-config-schema"

# Ensure correct ownership and Git safe directory
sudo chown -R developer:developer "$PROJECT_ROOT"
git config --global --add safe.directory "$PROJECT_ROOT"
git config --global --add safe.directory /IdeaProjects/envoy-config-schema

# Function to extract GitHub username
get_github_username() {
    local github_output
    github_output=$(ssh git@github.com 2>&1)
    if [[ $github_output =~ Hi[[:space:]]([^!]+)! ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        echo ""
    fi
}

# Check SSH agent forwarding
if [ -n "$SSH_AUTH_SOCK" ]; then
    echo "SSH agent forwarding is enabled."
    if [ -e "$SSH_AUTH_SOCK" ]; then
        echo "SSH_AUTH_SOCK is valid."
        if ssh-add -l &>/dev/null; then
            echo "SSH agent forwarding is working correctly."

            # Get GitHub username
            GITHUB_USERNAME=$(get_github_username)

            if [ -n "$GITHUB_USERNAME" ]; then
                echo "Detected GitHub username: $GITHUB_USERNAME"

                # Set Git config if not already set
                if [ -z "$(git config --global user.name)" ]; then
                    git config --global user.name "$GITHUB_USERNAME"
                    echo "Set Git user.name to $GITHUB_USERNAME"
                fi

                if [ -z "$(git config --global user.email)" ]; then
                    git config --global user.email "$GITHUB_USERNAME@users.noreply.github.com"
                    echo "Set Git user.email to $GITHUB_USERNAME@users.noreply.github.com"
                fi
            else
                echo "Could not detect GitHub username. Please set Git user.name and user.email manually."
            fi
        else
            echo "WARNING: SSH agent forwarding is enabled, but no identities are available."
        fi
    else
        echo "WARNING: SSH_AUTH_SOCK is set but the socket file does not exist."
    fi
else
    echo "WARNING: SSH agent forwarding is not enabled. You may have issues with Git operations."
fi

# Optional setup steps
if [[ "$AUTO_SETUP" == "true" ]]; then
    echo "Running automatic setup..."
    if command -v make &> /dev/null; then
        make -C "$PROJECT_ROOT" install-deps
        make -C "$PROJECT_ROOT" generate-json-schema
    else
        echo "WARNING: 'make' command not found. Skipping automatic setup."
    fi
else
    echo "Automatic setup skipped. Run 'make install-deps' and 'make generate-json-schema' manually if needed."
fi

echo "Development environment setup complete!"

echo "Setup complete. Final environment:"
echo "PATH: $PATH"
echo "SHELL: $SHELL"
echo "Current directory: $(pwd)"

# Execute the CMD
exec "$@"