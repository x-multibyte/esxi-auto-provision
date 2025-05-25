#!/bin/bash
set -e

# 默认路径
export ISO_OUTPUT_DIR="${ISO_OUTPUT_DIR:-$HOME/iso}"
export TEMPLATE_DIR="${TEMPLATE_DIR:-$HOME/templates}"

echo "[INFO] 创建默认目录..."
mkdir -p "$ISO_OUTPUT_DIR" "$TEMPLATE_DIR"

echo "[INFO] 安装依赖..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install genisoimage jq yq curl
elif [[ -f /etc/debian_version ]]; then
    sudo apt update
    sudo apt install -y genisoimage jq yq curl netplan.io cloud-init udev
fi

if ! command -v govc >/dev/null; then
    echo "[INFO] 安装 govc..."
    curl -L https://github.com/vmware/govmomi/releases/latest/download/govc_linux_amd64.gz | gunzip -c > /usr/local/bin/govc
    chmod +x /usr/local/bin/govc
fi

echo "[DONE] 所有依赖安装完成。"
