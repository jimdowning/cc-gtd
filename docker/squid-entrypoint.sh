#!/usr/bin/env bash
set -euo pipefail

# Ensure log and pid directories exist with correct ownership
mkdir -p /var/log/squid /var/run/squid
chown -R proxy:proxy /var/log/squid /var/run/squid

echo "Starting socat IMAP forwarder (localhost:1993 -> imap.gmail.com:993)..."
socat TCP-LISTEN:1993,fork,reuseaddr TCP:imap.gmail.com:993 &

echo "Starting socat MCP bridge forwarder (localhost:8787 -> host.docker.internal:8787)..."
socat TCP-LISTEN:8787,fork,reuseaddr TCP:host.docker.internal:8787 &

echo "Starting Squid proxy..."
# Tail logs to stdout so docker logs works, backgrounded
touch /var/log/squid/access.log /var/log/squid/cache.log
chown proxy:proxy /var/log/squid/access.log /var/log/squid/cache.log
tail -F /var/log/squid/access.log /var/log/squid/cache.log &

exec squid -N -f /etc/squid/squid.conf
