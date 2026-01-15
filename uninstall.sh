#!/bin/bash
set -e

INSTALL_DIR="/root/copyparty"

echo "[1/5] Stopping systemd service..."
if systemctl is-active --quiet copyparty; then
    systemctl stop copyparty
fi

echo "[2/5] Disabling systemd service..."
if systemctl is-enabled --quiet copyparty; then
    systemctl disable copyparty
fi

echo "[3/5] Removing systemd service..."
if [ -f /etc/systemd/system/copyparty.service ]; then
    rm -f /etc/systemd/system/copyparty.service
    systemctl daemon-reload
fi

echo "[4/5] Removing Copyparty files..."
if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
fi

echo "===================================="
echo "Copyparty has been completely uninstalled."
echo "===================================="
