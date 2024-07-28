# Start with Rocky Linux as the base image
FROM rockylinux:9.3

# Labels
LABEL maintainer="Patch Patrol Authors <info@margin.re>"
LABEL org.opencontainers.image.source="https://github.com/PatchPatrol/envoy-config-schema"
LABEL version="1.0"
LABEL description="Development environment for Envoy Config Schema"

# Install necessary tools
RUN dnf update -y && dnf install -y \
    git \
    make \
    protobuf-compiler \
    openssh-clients \
    gcc \
    gcc-c++ \
    zlib-devel \
    bzip2-devel \
    readline-devel \
    sqlite-devel \
    openssl-devel \
    tk-devel \
    libffi-devel \
    xz-devel \
    curl \
    sudo \
    tree \
    jq \
    && dnf clean all \
    && rm -rf /var/cache/dnf \
    && rm -rf /tmp/*

# Set up non-root user
RUN useradd -m -s /bin/bash -G wheel developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to non-root user
USER developer
WORKDIR /home/developer

# Install pyenv
RUN curl https://pyenv.run | bash
ENV PATH="/home/developer/.pyenv/bin:$PATH"
RUN echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc && \
    echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc

# Install Python 3.11 and set as global
RUN pyenv install 3.11 && \
    pyenv global 3.11

# Install poetry
RUN curl -sSL https://install.python-poetry.org | python3 -
ENV PATH="/home/developer/.local/bin:$PATH"

# Install nvm and Node LTS
ENV NVM_DIR="/home/developer/.nvm"
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install --lts && \
    nvm use --lts

# Install Go (cross-platform)
ENV GOROOT=/usr/local/go
ENV PATH=$PATH:/usr/local/go/bin
ENV GOPATH=/home/developer/go
RUN curl -sSL https://golang.org/dl/go1.21.6.linux-$(dpkg --print-architecture).tar.gz | sudo tar -C /usr/local -xzf -

# Install Go tools
RUN go install github.com/chrusty/protoc-gen-jsonschema/cmd/protoc-gen-jsonschema@latest && \
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest && \
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# Set up git to use the forwarded SSH agent
RUN git config --global url."git@github.com:".insteadOf "https://github.com/"

# Set up SSH for the forwarded agent
RUN mkdir -p ~/.ssh && \
    chmod 700 ~/.ssh && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts

# Copy entrypoint script
COPY --chown=developer:developer .devcontainer/entrypoint.dev.sh /usr/local/bin/entrypoint.dev.sh
RUN sudo chmod +x /usr/local/bin/entrypoint.dev.sh

# Copy setup script
COPY --chown=developer:developer setup-dev-environment.sh /workspace/
RUN chmod +x /workspace/setup-dev-environment.sh

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.dev.sh"]

# Set the default command
CMD ["/bin/bash"]