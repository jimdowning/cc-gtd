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

# Layer 4: trello-cli (Node.js package)
RUN npm install -g trello-cli

# Layer 5: Rust + tod (todoist CLI)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && . /root/.cargo/env \
    && cargo install tod
ENV PATH="/root/.cargo/bin:${PATH}"

# Layer 6: gcalcli
RUN pip3 install --break-system-packages gcalcli

# Layer 7: Install Claude Code at build time + bake checksum
RUN curl -fsSL https://claude.ai/install.sh | bash

# Verify and store checksum for runtime integrity checks
RUN CLAUDE_BIN=$(readlink -f /root/.local/bin/claude) \
    && CLAUDE_VERSION=$(/root/.local/bin/claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1) \
    && curl -fsSL "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/${CLAUDE_VERSION}/manifest.json" \
       -o /etc/claude-manifest.json \
    && CLAUDE_PLATFORM="linux-$(uname -m | sed 's/x86_64/x64/' | sed 's/aarch64/arm64/')" \
    && EXPECTED=$(jq -r ".platforms[\"${CLAUDE_PLATFORM}\"].checksum" /etc/claude-manifest.json) \
    && ACTUAL=$(sha256sum "$CLAUDE_BIN" | awk '{print $1}') \
    && echo "Build-time checksum: expected=$EXPECTED actual=$ACTUAL" \
    && [ "$EXPECTED" = "$ACTUAL" ] || { echo "CHECKSUM MISMATCH AT BUILD TIME"; exit 1; } \
    && echo "$EXPECTED" > /etc/claude-expected-checksum \
    && chmod 444 /etc/claude-expected-checksum /etc/claude-manifest.json
ENV PATH="/root/.local/bin:${PATH}"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /workspace/cc-gtd

ENTRYPOINT ["/entrypoint.sh"]
