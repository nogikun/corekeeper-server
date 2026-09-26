#!/usr/bin/env bash
# Proxmox VE ホスト上で実行し、Core Keeper サーバー入りの LXC を作成する。
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/nogikun/corekeeper-server/main/proxmox-install.sh)"
# 環境変数で上書き可: CTID=200 STORAGE=local-zfs MEMORY=8192 bash -c "$(curl ...)"
set -euo pipefail

CTID=${CTID:-$(pvesh get /cluster/nextid)}
CT_HOSTNAME=${CT_HOSTNAME:-corekeeper}
STORAGE=${STORAGE:-local-lvm}          # rootfs 用
TEMPLATE_STORAGE=${TEMPLATE_STORAGE:-local}
BRIDGE=${BRIDGE:-vmbr0}
DISK=${DISK:-20}                        # GB
CORES=${CORES:-2}
MEMORY=${MEMORY:-4096}                  # MB
REPO=${REPO:-https://github.com/nogikun/corekeeper-server.git}
BRANCH=${BRANCH:-main}

command -v pct >/dev/null || { echo "Proxmox VE ホストで実行してください" >&2; exit 1; }

# Debian 12 テンプレートを取得
pveam update
TEMPLATE=$(pveam available --section system | awk '/debian-12-standard/ {print $2}' | sort -V | tail -n1)
pveam list "$TEMPLATE_STORAGE" | grep -q "$TEMPLATE" || pveam download "$TEMPLATE_STORAGE" "$TEMPLATE"

# Docker を動かすため nesting/keyctl を有効化した非特権コンテナ
pct create "$CTID" "$TEMPLATE_STORAGE:vztmpl/$TEMPLATE" \
  --hostname "$CT_HOSTNAME" --cores "$CORES" --memory "$MEMORY" --swap 1024 \
  --rootfs "$STORAGE:$DISK" --net0 "name=eth0,bridge=$BRIDGE,ip=dhcp" \
  --unprivileged 1 --features nesting=1,keyctl=1 --onboot 1
pct start "$CTID"

# ネットワークが上がるまで待つ
pct exec "$CTID" -- bash -c 'for i in $(seq 60); do getent hosts github.com >/dev/null && exit 0; sleep 1; done; exit 1'

# 既存の server/ 構成 (Dockerfile + docker-compose.yml) をそのまま使う
pct exec "$CTID" -- bash -euo pipefail -c "
  apt-get update
  apt-get install -y curl git ca-certificates
  curl -fsSL https://get.docker.com | sh
  git clone --depth 1 -b '$BRANCH' '$REPO' /opt/corekeeper-server
  cd /opt/corekeeper-server/server
  docker build -t escaping/core-keeper-dedicated:latest .
  docker compose up -d
"

echo "完了: CT $CTID ($CT_HOSTNAME)"
echo "Game ID 確認: pct exec $CTID -- cat /opt/corekeeper-server/server/server-files/GameID.txt"
echo "ログ:         pct exec $CTID -- docker logs -f core-keeper-dedicated"
