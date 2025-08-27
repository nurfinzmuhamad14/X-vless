#!/bin/bash

UUID_FILE=/uuid.txt
if [ ! -f "$UUID_FILE" ]; then
  uuidgen > $UUID_FILE
fi
UUID=$(cat $UUID_FILE)

cat > /xray.json <<EOF
{
  "inbounds": [
    {
      "port": $PORT,
      "protocol": "vless",
      "settings": {
        "clients": [
          { "id": "$UUID", "level": 0, "email": "vless" }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": { "path": "/ws" }
      }
    },
    {
      "port": $PORT,
      "protocol": "vmess",
      "settings": {
        "clients": [
          { "id": "$UUID", "alterId": 0 }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": { "path": "/ws" }
      }
    }
  ],
  "outbounds": [
    { "protocol": "freedom" },
    { "protocol": "blackhole", "settings": {}, "tag": "blocked" }
  ]
}
EOF

echo "====================================="
echo "✅ Xray 已启动"
echo "UUID: $UUID"
echo "VLESS 节点: vless://$UUID@your-domain:$PORT?path=/ray&security=none&type=ws"
echo "VMESS 节点 JSON 配置:"
echo "{"
echo "  \"v\": \"2\","
echo "  \"ps\": \"railway-vmess\","
echo "  \"add\": \"your-domain\","
echo "  \"port\": \"$PORT\","
echo "  \"id\": \"$UUID\","
echo "  \"aid\": \"0\","
echo "  \"net\": \"ws\","
echo "  \"type\": \"none\","
echo "  \"host\": \"your-domain\","
echo "  \"path\": \"/ray\","
echo "  \"tls\": \"\""
echo "}"
echo "====================================="

/usr/bin/xray -config /xray.json
