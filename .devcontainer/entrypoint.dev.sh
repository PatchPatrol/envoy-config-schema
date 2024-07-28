#!/bin/bash

# Set up the PATH
export PATH="/home/developer/.pyenv/bin:/home/developer/.local/bin:/home/developer/.nvm/versions/node/$(nvm current)/bin:/usr/local/go/bin:$PATH"

# MOTD Banner
echo "Welcome to the Envoy Config Schema Dev Container!"
echo "================================================"
echo
echo "Please set up your Git commit details:"
echo "git config --global user.name \"Your Name\""
echo "git config --global user.email \"your.email@example.com\""
echo

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
echo "Environment is ready. Happy coding!"
echo

# Execute the command passed to docker run
exec "$@"