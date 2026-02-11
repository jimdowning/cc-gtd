#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/claude-bin"

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

echo "Installing Claude Code via temporary container..."
docker run --rm \
  -v "$OUTPUT_DIR":/output \
  debian:bookworm-slim bash -c '
    apt-get update && apt-get install -y --no-install-recommends ca-certificates curl jq
    curl -fsSL https://claude.ai/install.sh | bash
    CLAUDE_BIN=$(readlink -f /root/.local/bin/claude)
    CLAUDE_VERSION=$(/root/.local/bin/claude --version 2>/dev/null | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" | head -1)
    PLATFORM="linux-$(uname -m | sed "s/x86_64/x64/" | sed "s/aarch64/arm64/")"
    curl -fsSL "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/${CLAUDE_VERSION}/manifest.json" \
      -o /tmp/manifest.json
    EXPECTED=$(jq -r ".platforms[\"${PLATFORM}\"].checksum" /tmp/manifest.json)
    ACTUAL=$(sha256sum "$CLAUDE_BIN" | awk "{print \$1}")
    if [ "$EXPECTED" != "$ACTUAL" ]; then
      echo "FATAL: checksum mismatch expected=$EXPECTED actual=$ACTUAL" >&2
      exit 1
    fi
    echo "Checksum verified: $ACTUAL"
    # Copy the full installation to output
    cp -a /root/.local/bin/claude /output/claude-entry
    CLAUDE_DIR=$(dirname "$CLAUDE_BIN")
    cp -a "$(dirname "$CLAUDE_DIR")" /output/claude-app
    # Write a wrapper that invokes the real binary
    cat > /output/claude <<WRAPPER
#!/usr/bin/env bash
exec /opt/claude/claude-app/$(basename "$CLAUDE_DIR")/$(basename "$CLAUDE_BIN") "\$@"
WRAPPER
    chmod +x /output/claude
    echo "$CLAUDE_VERSION" > /output/VERSION
  '

echo "Claude Code $(cat "$OUTPUT_DIR/VERSION") installed to $OUTPUT_DIR"
