#!/bin/bash
set -e
ISO_NAME="$1"
VM_NAME="${ISO_NAME%.iso}"

[ -z "$GOVC_URL" ] && echo "请设置 GOVC_URL 环境变量。" && exit 1
[ ! -f "$HOME/iso/$ISO_NAME" ] && echo "找不到 ISO：$ISO_NAME" && exit 1

echo "[INFO] 上传 ISO..."
govc datastore.upload "$HOME/iso/$ISO_NAME" "iso/$ISO_NAME"

echo "[INFO] 创建 VM..."
govc vm.create -m=2048 -c=2 -g=ubuntu64Guest -disk=20GB -iso="iso/$ISO_NAME" -net.adapter=vmxnet3 "$VM_NAME"

echo "[DONE] 已创建 VM: $VM_NAME"
