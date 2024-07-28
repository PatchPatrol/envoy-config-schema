#!/bin/bash
set -e

echo "Starting setup-dev-environment.sh"

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
    echo "Unable to determine the project mount point."
    exit 1
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

# Setup shell environment
if [[ "$SETUP_ZSH" == "true" || "$SHELL" == *"zsh"* ]]; then
    echo "Setting up Zsh environment..."
    make -C "$PROJECT_ROOT" -f "$PROJECT_ROOT/Makefile" devshell-zsh
    echo "Zsh setup complete. Please restart your shell or run 'zsh' to start using it."
else
    # Setup colored bash prompt
    echo "Setting up colored Bash prompt..."
    echo 'export PS1="\[\033[38;5;11m\]\u\[$(tput sgr0)\]\[\033[38;5;15m\]@\h:\[$(tput sgr0)\]\[\033[38;5;6m\][\w]:\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]"' >> "$HOME/.bashrc"
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