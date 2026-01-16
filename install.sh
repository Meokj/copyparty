#!/bin/bash
set -e

# ======================
# 参数
# ======================
PORT="$1"
ADMIN_USER="$2"
ADMIN_PASS="$3"

if [ -z "$PORT" ] || [ -z "$ADMIN_USER" ] || [ -z "$ADMIN_PASS" ]; then
  echo "用法: bash install_copyparty.sh <port> <admin_user> <admin_pass>"
  exit 1
fi

INSTALL_DIR="/root/copyparty"
DATA_DIR="$INSTALL_DIR/data"

echo "========== Copyparty 一键安装 =========="

# ======================
# 1. 安装依赖
# ======================
echo "[1/6] Installing dependencies..."
apt update -y
apt install -y python3 wget nginx curl

# ======================
# 2. 创建目录
# ======================
echo "[2/6] Creating directories..."
mkdir -p "$DATA_DIR"/{public,private,inbox,sharex}

# ======================
# 3. 下载 copyparty
# ======================
echo "[3/6] Downloading copyparty..."
wget -q -N https://github.com/9001/copyparty/releases/latest/download/copyparty-sfx.py \
  -O "$INSTALL_DIR/copyparty-sfx.py"
chmod +x "$INSTALL_DIR/copyparty-sfx.py"

# ======================
# 4. 生成配置文件
# ======================
echo "[4/6] Creating config..."
cat > "$INSTALL_DIR/copyparty.conf" <<EOF
[global]
  p: $PORT
  z, qr
  e2dsa
  e2ts

[accounts]
  $ADMIN_USER: $ADMIN_PASS

[/]
  $DATA_DIR
  accs:
    r: *

[/public]
  $DATA_DIR/public
  accs:
    r: *
    rwmd: ADMIN_USER

[/private]
  $DATA_DIR/private
  accs:
    rwmd: $ADMIN_USER

[/inbox]
  $DATA_DIR/inbox
  accs:
    w: $ADMIN_USER
  flags:
    e2d
    nodupe

[/sharex]
  $DATA_DIR/sharex
  accs:
    wG: $ADMIN_USER
    rwmd: $ADMIN_USER
  flags:
    e2d, d2t, fk: 4
EOF

# ======================
# 5. 启动脚本
# ======================
echo "[5/6] Creating start script..."
cat > "$INSTALL_DIR/start.sh" <<EOF
#!/bin/bash
exec /usr/bin/python3 $INSTALL_DIR/copyparty-sfx.py \\
  -c $INSTALL_DIR/copyparty.conf \\
  --http-only \\
  --xff-hdr x-forwarded-for \\
  --xff-src 127.0.0.1/32 \\
  --rproxy 1
EOF

chmod +x "$INSTALL_DIR/start.sh"

# ======================
# 6. systemd 服务
# ======================
echo "[6/6] Creating systemd service..."
cat > /etc/systemd/system/copyparty.service <<EOF
[Unit]
Description=Copyparty File Server
After=network.target

[Service]
ExecStart=$INSTALL_DIR/start.sh
WorkingDirectory=$INSTALL_DIR
Restart=always
RestartSec=3
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable copyparty
systemctl restart copyparty

sleep 3

# ======================
# 验证
# ======================
if curl -s http://127.0.0.1:$PORT/ >/dev/null; then
  echo "======================================"
  echo "✅ Copyparty 安装成功"
  echo
  echo "访问地址: http://<服务器IP>:$PORT/"
  echo "管理员:   $ADMIN_USER"
  echo "密码:     $ADMIN_PASS"
else
  echo "❌ Copyparty 启动失败"
  journalctl -u copyparty -n 50 --no-pager
fi
