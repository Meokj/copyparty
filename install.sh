#!/bin/bash
set -e

PORT=$1
USERNAME=$2
PASSWORD=$3

INSTALL_DIR="/opt/copyparty"
DATA_DIR="$INSTALL_DIR/data"

echo "[1/5] Installing dependencies..."
apt update
apt install -y python3 wget nginx

echo "[2/5] Creating directories..."
mkdir -p $INSTALL_DIR $DATA_DIR

echo "[3/5] Downloading copyparty..."
wget -N https://github.com/9001/copyparty/releases/latest/download/copyparty-sfx.py -O $INSTALL_DIR/copyparty-sfx.py
chmod +x $INSTALL_DIR/copyparty-sfx.py

echo "[4/5] Creating start script..."
cat > $INSTALL_DIR/start.sh <<EOF
#!/bin/bash
PORT="$1"      
USERNAME="$2"   
PASSWORD="$3"  
DATA_DIR="/opt/copyparty/data"
INSTALL_DIR="/opt/copyparty"
/usr/bin/python3 $INSTALL_DIR/copyparty-sfx.py -v $DATA_DIR -a "\$USERNAME:\$PASSWORD" --http-only -p \$PORT
EOF

chmod +x $INSTALL_DIR/start.sh

echo "[5/5] Creating systemd service..."
cat >/etc/systemd/system/copyparty.service <<EOF
[Unit]
Description=copyparty file server
After=network.target

[Service]
ExecStart=$INSTALL_DIR/start.sh $PORT $USERNAME $PASSWORD
WorkingDirectory=$INSTALL_DIR
Restart=always
RestartSec=5
StartLimitBurst=3
StartLimitIntervalSec=60
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable copyparty
systemctl start copyparty

echo "===================================="
echo "Copyparty installed successfully!"
echo "Access URL: http://<your-server-ip>/"
echo "Username: $USERNAME"
echo "Password: $PASSWORD"
echo "===================================="
