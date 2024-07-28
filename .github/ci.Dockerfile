FROM golang:1.19

# Install necessary tools
RUN apt-get update && apt-get install -y \
    git \
    make \
    protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*

# Install Go tools
RUN go install github.com/chrusty/protoc-gen-jsonschema/cmd/protoc-gen-jsonschema@latest \
    && go install google.golang.org/protobuf/cmd/protoc-gen-go@latest \
    && go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# Set the working directory in the container
WORKDIR /workspace

# Set up the environment
ENV PATH="/go/bin:/usr/local/go/bin:${PATH}"

# Copy the necessary files
COPY . .

# Run the schema generation
CMD ["make", "generate-json-schema"]
