# Start with Rocky Linux as the base image
FROM rockylinux:9.3

# Labels
LABEL maintainer="Patch Patrol Authors <info@margin.re>"
LABEL org.opencontainers.image.source="https://github.com/PatchPatrol/envoy-config-schema"
LABEL version="1.0"
LABEL description="CI environment for Envoy Config Schema"

# Install necessary tools
RUN dnf update -y && dnf install --allowerasing -y \
    git \
    make \
    wget \
    golang \
    && dnf clean all \
    && rm -rf /var/cache/dnf \
    && rm -rf /tmp/*

# Copy protobuf from the protobuf image
COPY --from=ghcr.io/patchpatrol/envoy-config-schema-protobuf:latest /usr/local/bin/protoc /usr/local/bin/
COPY --from=ghcr.io/patchpatrol/envoy-config-schema-protobuf:latest /usr/local/include/google /usr/local/include/google
COPY --from=ghcr.io/patchpatrol/envoy-config-schema-protobuf:latest /usr/local/lib/libprotoc.so* /usr/local/lib/
COPY --from=ghcr.io/patchpatrol/envoy-config-schema-protobuf:latest /usr/local/lib/libprotobuf.so* /usr/local/lib/

# Set up Go environment
ENV GOROOT=/usr/local/go
ENV PATH=$PATH:/usr/local/go/bin
ENV GOPATH=/go

# Install Go tools
RUN go install github.com/chrusty/protoc-gen-jsonschema/cmd/protoc-gen-jsonschema@latest && \
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest && \
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# Set the working directory in the container
WORKDIR /workspace

# Copy the necessary files
COPY . .

# Run the schema generation
CMD ["make", "generate-json-schema"]