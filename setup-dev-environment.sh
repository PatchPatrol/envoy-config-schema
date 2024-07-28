#!/bin/bash
set -e

# Check if we're in a dev container environment
if [ -d "/workspaces/envoy-config-schema" ]; then
    # Ensure correct ownership and Git safe directory
    sudo chown developer:developer /workspaces/envoy-config-schema
    git config --global --add safe.directory /workspaces/envoy-config-schema
else
    echo "Not running in a standard dev container environment. Skipping workspace setup."
fi

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
        make install-deps
        make generate-json-schema
    else
        echo "WARNING: 'make' command not found. Skipping automatic setup."
    fi
else
    echo "Automatic setup skipped. Run 'make install-deps' and 'make generate-json-schema' manually if needed."
fi

echo "Development environment setup complete!"

# If we're not in an interactive shell, keep the container running
if [[ ! -t 0 ]]; then
    echo "Container is running in non-interactive mode. Keeping it alive..."
    tail -f /dev/null
fi