FROM rockylinux:9.3 AS protobuf-builder

RUN dnf update -y && dnf install -y \
    wget \
    make \
    gcc \
    gcc-c++ \
    && dnf clean all

RUN wget https://github.com/protocolbuffers/protobuf/releases/download/v3.19.4/protobuf-all-3.19.4.tar.gz && \
    tar -xzvf protobuf-all-3.19.4.tar.gz && \
    cd protobuf-3.19.4 && \
    ./configure && \
    make && \
    make install && \
    ldconfig && \
    cd .. && \
    rm -rf protobuf-3.19.4 protobuf-all-3.19.4.tar.gz

FROM scratch
COPY --from=protobuf-builder /usr/local/bin/protoc /usr/local/bin/protoc
COPY --from=protobuf-builder /usr/local/include/google /usr/local/include/google
COPY --from=protobuf-builder /usr/local/lib/libprotoc.so* /usr/local/lib/
COPY --from=protobuf-builder /usr/local/lib/libprotobuf.so* /usr/local/lib/