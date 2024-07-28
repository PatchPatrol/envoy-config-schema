#!/bin/bash
set -e

# MOTD Banner
echo "Welcome to the Envoy Config Schema Dev Container!"
echo "================================================"
echo

# Ensure correct ownership and Git safe directory
sudo chown developer:developer /workspaces/envoy-config-schema
git config --global --add safe.directory /workspaces/envoy-config-schema

# Check SSH agent forwarding
if [ -n "$SSH_AUTH_SOCK" ]; then
    echo "SSH agent forwarding is enabled."
    # Verify if the socket actually exists
    if [ -e "$SSH_AUTH_SOCK" ]; then
        echo "SSH_AUTH_SOCK is valid."
        # Try to list keys to verify forwarding is working
        if ssh-add -l &>/dev/null; then
            echo "SSH agent forwarding is working correctly."
        else
            echo "WARNING: SSH agent forwarding is enabled, but no identities are available."
        fi
    else
        echo "WARNING: SSH_AUTH_SOCK is set but the socket file does not exist."
    fi
else
    echo "WARNING: SSH agent forwarding is not enabled. You may have issues with Git operations."
fi

echo

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

echo
echo "Please verify your Git commit details:"
echo "git config --global user.name \"$(git config --global user.name)\""
echo "git config --global user.email \"$(git config --global user.email)\""
echo

# Optional setup steps
if [[ "$AUTO_SETUP" == "true" ]]; then
    echo "Running automatic setup..."
    make install-deps
    make generate-json-schema
else
    echo "Automatic setup skipped. Run 'make install-deps' and 'make generate-json-schema' manually if needed."
fi

echo "Development environment setup complete!"