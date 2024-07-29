FROM rust:1.69 as builder

# Set tre version
ARG TRE_VERSION=0.4.0

# Clone tre repository and build
RUN git clone --depth 1 --branch v${TRE_VERSION} https://github.com/dduan/tre.git && \
    cd tre && \
    cargo build --release

# Final stage - just the binary
FROM scratch
COPY --from=builder /tre/target/release/tre /tre