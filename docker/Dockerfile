FROM debian:bookworm-slim

# Layer 1: System packages (most stable)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git jq bash coreutils procps python3 python3-pip \
    build-essential pkg-config libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Layer 2: Node.js 22 via NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# Layer 3: ripgrep from apt (available for both amd64 and arm64)
RUN apt-get update && apt-get install -y --no-install-recommends ripgrep \
    && rm -rf /var/lib/apt/lists/*

# Layer 4: trello-cli is mounted from host as self-contained binary
# See docker-compose.yml volume: ./trello-cli-bin:/opt/trello-cli:ro

# Layer 5: Rust + tod (todoist CLI) — installed as root, then copied
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && . /root/.cargo/env \
    && cargo install tod \
    && cp /root/.cargo/bin/tod /usr/local/bin/tod \
    && rm -rf /root/.cargo /root/.rustup

# Layer 6: gcalcli
RUN pip3 install --break-system-packages gcalcli PySocks

# Layer 7: Non-root user for Claude Code (--dangerously-skip-permissions
# refuses to run as root)
RUN useradd -m -s /bin/bash claude
ENV HOME=/home/claude

# Claude Code is installed on the host via host-install-claude.sh
# and mounted read-only at /opt/claude
ENV PATH="/home/claude/.local/bin:/opt/claude:${PATH}"

# Pre-create paths needed at runtime on the read-only root filesystem
# .claude.json must be writable at runtime, so symlink it into the writable
# .claude bind mount. The entrypoint seeds the actual file there.
RUN mkdir -p /home/claude/.local/bin \
    && ln -s /home/claude/.claude/.claude.json /home/claude/.claude.json \
    && chown -R claude:claude /home/claude

WORKDIR /workspace/cc-gtd

ENTRYPOINT ["/entrypoint.sh"]
