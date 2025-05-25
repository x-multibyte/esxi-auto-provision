#!/bin/bash
set -e

# 用户输入参数
read -p "Ubuntu 版本 (如 22.04)： " ubuntu_version
read -p "主机名： " hostname
read -p "用户名： " username
read -p "SSH 公钥路径 (~/.ssh/id_rsa.pub)： " ssh_path
read -p "使用 DHCP？[y/n]： " use_dhcp
read -p "导入现成 user-data.yaml？[路径留空则跳过]： " existing_userdata

export ISO_OUTPUT_DIR="${ISO_OUTPUT_DIR:-$HOME/iso}"
export TEMPLATE_DIR="${TEMPLATE_DIR:-$HOME/templates}"
mkdir -p "$ISO_OUTPUT_DIR"

# 自动探测网络接口名
iface=$(ip link | grep -v lo | awk -F: '/^[0-9]+: / {print $2; exit}' | tr -d ' ')

# 拷贝模板
cp "$TEMPLATE_DIR/user-data.template" user-data
cp "$TEMPLATE_DIR/meta-data.template" meta-data
cp "$TEMPLATE_DIR/netplan.template" network-config

# 填充变量
if [[ -n "$existing_userdata" && -f "$existing_userdata" ]]; then
    cp "$existing_userdata" user-data
else
    sed -i "s|__USERNAME__|$username|g" user-data
    sed -i "s|__PUBKEY__|$(cat $ssh_path)|g" user-data
fi

sed -i "s|__HOSTNAME__|$hostname|g" meta-data

if [[ "$use_dhcp" == "y" ]]; then
    cat > network-config <<EOF
network:
  version: 2
  ethernets:
    $iface:
      dhcp4: true
EOF
else
    read -p "IP 地址： " ip
    read -p "网关： " gw
    read -p "子网掩码 (CIDR，如24)： " mask
    cat > network-config <<EOF
network:
  version: 2
  ethernets:
    $iface:
      addresses: [$ip/$mask]
      gateway4: $gw
      nameservers:
        addresses: [8.8.8.8,8.8.4.4]
EOF
fi

mkdir -p iso_tmp
cp user-data meta-data network-config iso_tmp/
cd iso_tmp
genisoimage -output "../$ISO_OUTPUT_DIR/${hostname}.iso" -volid cidata -joliet -rock user-data meta-data network-config
cd ..
rm -rf iso_tmp

echo "[DONE] ISO 生成：$ISO_OUTPUT_DIR/${hostname}.iso"
