# Start with a base image that includes Go
FROM golang:1.19

# Install necessary tools
RUN apt-get update && apt-get install -y \
    git \
    make \
    protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*

# Install Go tools
RUN go install github.com/chrusty/protoc-gen-jsonschema/cmd/protoc-gen-jsonschema@v1.3.5 \
    && go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.26 \
    && go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.1

# Set the working directory in the container
WORKDIR /workspace

# Copy the current directory contents into the container
COPY . .

# Initialize and update git submodules
RUN git submodule update --init --recursive

# Set up the environment
ENV PATH="/go/bin:${PATH}"

# Command to run when starting the container
CMD ["/bin/bash"]