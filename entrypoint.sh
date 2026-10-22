#!/bin/sh
set -e
: "${UUID:?need UUID env}"
WSPATH="${WSPATH:-/$(printf %s "$UUID" | cut -d- -f1)}"
PORT="${PORT:-8080}"
cat > /tmp/config.json <<JSON
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "listen": "0.0.0.0",
      "port": ${PORT},
      "protocol": "vless",
      "settings": { "clients": [ { "id": "${UUID}" } ], "decryption": "none" },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": { "path": "${WSPATH}" }
      },
      "sniffing": { "enabled": true, "destOverride": [ "http", "tls" ] }
    }
  ],
  "outbounds": [ { "protocol": "freedom", "tag": "direct" } ]
}
JSON
XRAY_BIN="$(command -v xray || true)"
[ -z "$XRAY_BIN" ] && XRAY_BIN=/usr/bin/xray
exec "$XRAY_BIN" run -config /tmp/config.json
