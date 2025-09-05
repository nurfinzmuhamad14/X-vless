#!/bin/bash
# Auto Install VLESS + Xray Core (Debian/Ubuntu)

domain="udyneos.my.id"   # ganti dengan domain kamu
uuid=ff918e3-02c0-5c49-8cfa-2d41b8d8b88e

apt update -y && apt upgrade -y
apt install -y curl socat cron bash-completion wget unzip

# Install acme.sh untuk SSL
curl https://get.acme.sh | sh
~/.acme.sh/acme.sh --register-account -m admin@$domain
~/.acme.sh/acme.sh --issue -d $domain --standalone --force
~/.acme.sh/acme.sh --install-cert -d $domain \
  --key-file       /etc/xray/private.key \
  --fullchain-file /etc/xray/cert.crt

# Install Xray-core
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# Buat config VLESS
cat > /usr/local/etc/xray/config.json << EOF
{
  "inbounds": [
    {
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "$uuid",
            "level": 0,
            "email": "user@$domain"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "/etc/xray/cert.crt",
              "keyFile": "/etc/xray/private.key"
            }
          ]
        },
        "wsSettings": {
          "path": "/vless"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
EOF

# Enable & Start Xray
systemctl enable xray
systemctl restart xray

echo -e "\n==== INSTALL SELESAI ===="
echo "Domain   : $domain"
echo "UUID     : $uuid"
echo "Protocol : VLESS + TLS + WS"
echo "Port     : 443"
echo "Path     : /vless"
echo "Config   : /usr/local/etc/xray/config.json"
