#!/bin/bash
set -e

# Ensure correct ownership and Git safe directory
sudo chown developer:developer /workspaces/envoy-config-schema
git config --global --add safe.directory /workspaces/envoy-config-schema

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

# Optional setup steps
if [[ "$AUTO_SETUP" == "true" ]]; then
    echo "Running automatic setup..."
    make install-deps
    make generate-json-schema
else
    echo "Automatic setup skipped. Run 'make install-deps' and 'make generate-json-schema' manually if needed."
fi

echo "Development environment setup complete!"