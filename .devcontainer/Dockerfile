FROM rockylinux:9.3

LABEL maintainer="Patch Patrol Authors <info@margin.re>"
LABEL org.opencontainers.image.source="https://github.com/PatchPatrol/envoy-config-schema"
LABEL version="1.0"
LABEL description="Development environment for Envoy Config Schema"

# Install necessary packages
RUN dnf install -y epel-release && \
    dnf update -y && \
    dnf install --allowerasing -y \
    git \
    make \
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
    wget \
    golang \
    procps \
    zsh \
    which \
    autojump \
    autojump-zsh \
    util-linux-user \
    && dnf clean all \
    && rm -rf /var/cache/dnf \
    && rm -rf /tmp/*

# Set up non-root user
RUN useradd -m -s /bin/zsh -G wheel developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to non-root user
USER developer
WORKDIR /home/developer

# Install pyenv
RUN curl https://pyenv.run | bash
ENV PATH="/home/developer/.pyenv/bin:$PATH"
RUN echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.zshrc && \
    echo 'eval "$(pyenv init -)"' >> ~/.zshrc && \
    echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.zshrc

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

# Install Go tools
RUN go install github.com/chrusty/protoc-gen-jsonschema/cmd/protoc-gen-jsonschema@v1.3.5 && \
    go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.26 && \
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.1


# Install tre
#COPY --from=ghcr.io/patchpatrol/envoy-config-schema-tre:latest /tre /usr/local/bin/tre

# Copy protobuf from the protobuf image
COPY --from=ghcr.io/patchpatrol/envoy-config-schema-protobuf:latest /usr/local/bin/protoc /usr/local/bin/
COPY --from=ghcr.io/patchpatrol/envoy-config-schema-protobuf:latest /usr/local/include/google /usr/local/include/google
COPY --from=ghcr.io/patchpatrol/envoy-config-schema-protobuf:latest /usr/local/lib/libprotoc.so* /usr/local/lib/
COPY --from=ghcr.io/patchpatrol/envoy-config-schema-protobuf:latest /usr/local/lib/libprotobuf.so* /usr/local/lib/

# Set up git to use the forwarded SSH agent
RUN git config --global url."git@github.com:".insteadOf "https://github.com/"

# Set up SSH for the forwarded agent
RUN mkdir -p ~/.ssh && \
    chmod 700 ~/.ssh && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts

# Copy dotfiles individually
COPY --chown=developer:developer dotfiles/bashrc /home/developer/.bashrc
COPY --chown=developer:developer dotfiles/zshrc /home/developer/.zshrc
COPY --chown=developer:developer dotfiles/p10k.zsh /home/developer/.p10k.zsh
COPY --chown=developer:developer dotfiles/shellrc /home/developer/.shellrc
COPY --chown=developer:developer dotfiles/zsh_plugins.txt /home/developer/.zsh_plugins.txt

# Copy setup script
COPY --chown=developer:developer setup-dev-environment.sh /home/developer/
RUN chmod +x /home/developer/setup-dev-environment.sh

# Install Antidote
RUN git clone --depth=1 https://github.com/mattmc3/antidote.git ${HOME}/.antidote

# Set shell to zsh and source .zshrc
SHELL ["/bin/zsh", "-c"]

# Set the entrypoint to run the setup script
ENTRYPOINT ["/home/developer/setup-dev-environment.sh"]

# Set the default command
CMD ["/bin/zsh", "-l"]