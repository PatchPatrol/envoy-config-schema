FROM golang:1.19

# Install necessary tools
RUN apt-get update && apt-get install -y \
    git \
    make \
    protobuf-compiler \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Install Go tools
RUN go install github.com/chrusty/protoc-gen-jsonschema/cmd/protoc-gen-jsonschema@latest \
    && go install google.golang.org/protobuf/cmd/protoc-gen-go@latest \
    && go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# Set the working directory in the container
WORKDIR /workspace

# Set up git to use the forwarded SSH agent
RUN git config --global url."git@github.com:".insteadOf "https://github.com/"

# Set up SSH for the forwarded agent
RUN mkdir -p ~/.ssh && \
    chmod 700 ~/.ssh && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts

# Set up the environment
ENV PATH="/go/bin:/usr/local/go/bin:${PATH}"

# Command to run when starting the container
CMD ["/bin/bash"]