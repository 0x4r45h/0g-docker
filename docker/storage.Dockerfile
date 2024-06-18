FROM rust:1.78.0-bookworm AS rust-builder
WORKDIR /root
# The version should be matching the version set above
RUN rustup toolchain install 1.78.0 --profile minimal

RUN apt-get update && apt-get install -y \
    build-essential \
    clang-tools-14 \
    git \
    libssl-dev \
    pkg-config \
    protobuf-compiler \
    libudev-dev \
    && apt-get clean

ARG STORAGE_NODE_TAG=v0.3.1

RUN git clone -b $STORAGE_NODE_TAG https://github.com/0glabs/0g-storage-node.git
WORKDIR 0g-storage-node
RUN git submodule update --init
RUN cargo build --release

FROM debian:bookworm-slim AS runtime
RUN apt-get update && apt-get install -y \
    curl \
    nano \
    jq \
    dnsutils \
    wget \
    unzip \
    perl \
    lz4 \
    git \
    inotify-tools \
    procps \
    supervisor \
    iputils-ping \
    && apt-get clean

RUN useradd -m zerog
USER zerog
WORKDIR /home/zerog

COPY --from=rust-builder /root/0g-storage-node/target/release/zgs_node /usr/local/bin/zgs_node
COPY --chown=zerog:zerog configs/storage-config.toml configs/storage-config.toml
COPY --chown=zerog:zerog docker/storage-entrypoint.sh /opt/storage-entrypoint.sh
COPY --chown=zerog:zerog configs/storage-supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY --chown=zerog:zerog configs/log_watcher.sh /usr/local/bin/log_watcher.sh
COPY --chown=zerog:zerog configs/log_cleaner.sh /usr/local/bin/log_cleaner.sh
RUN chmod +x /usr/local/bin/log_cleaner.sh /usr/local/bin/log_watcher.sh /opt/storage-entrypoint.sh

RUN mkdir -p db log network && touch log/empty.log

ENTRYPOINT ["/opt/storage-entrypoint.sh"]
