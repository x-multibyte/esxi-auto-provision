#!/bin/bash
set -e
CONFIG=$1
[ ! -f "$CONFIG" ] && echo "配置文件未找到: $CONFIG" && exit 1

instances=$(yq e '.instances | length' "$CONFIG")
for ((i=0; i<instances; i++)); do
  hostname=$(yq e ".instances[$i].hostname" "$CONFIG")
  username=$(yq e ".instances[$i].username" "$CONFIG")
  ip=$(yq e ".instances[$i].ip" "$CONFIG")
  dhcp=$(yq e ".instances[$i].dhcp" "$CONFIG")
  echo "[INFO] 生成 $hostname ..."
  bash scripts/generate_iso.sh <<< "$ubuntu_version
$hostname
$username
$HOME/.ssh/id_rsa.pub
$([[ "$dhcp" == "true" ]] && echo y || echo n)
"
done
