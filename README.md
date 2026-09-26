# Core Keeper Dedicated Server
Forked from [escapingnetwork/core-keeper-dedicated](https://github.com/escapingnetwork/core-keeper-dedicated)

![corekeeper](https://user-images.githubusercontent.com/136487/168213246-7f561105-136e-47fa-abd9-fac1c97ca48d.png)

Core Keeperの専用サーバーを構築するためのリポジトリです。

---

##  事前準備: `task` コマンドのインストール

本リポジトリでは、ビルドや起動を簡略化するために [go-task (Task)](https://taskfile.dev/) を使用しています。
ご利用のOS（標準のコマンドライン）に合わせて以下のコマンドを使用しインストールしてください。

### Windows
```powershell
# Wingetを使用する場合 (推奨)
winget install Task.Task

# Scoopを使用する場合
scoop install task

# Chocolateyを使用する場合
choco install go-task
```

### macOS
Homebrewを使用してインストールします。
```bash
brew install go-task
```

### Linux
公式のインストールスクリプトを使用するか、各種パッケージマネージャでインストールします。
```bash
# インストールスクリプトを使用する場合
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"

# Homebrewを使用する場合 (Linuxbrew)
brew install go-task
```

インストール後、以下のコマンドでバージョンが表示されればセットアップは完了です。
```bash
task --version
```

---

## 🚀 使い方 (Taskコマンド)

リポジトリのルートディレクトリ（`Taskfile.yml` がある階層）で標準のコマンドライン（ターミナルやPowerShell）を開き、以下のコマンドを実行します。
（OSに依存せず、すべてのOSで共通のコマンドで操作できます）

| コマンド | 説明 |
| --- | --- |
| `task` | 利用可能なすべてのコマンド一覧と説明（日本語）を表示します。 |
| `task init` | 🛠️ 開発環境の初期セットアップ（pre-commit等のインストール）を行います。 |
| `task sync` | 🔄 サブモジュールからDockerfileなどを `server` ディレクトリに同期コピーします。 |
| `task submodule:update`| 📦 サブモジュールを最新状態に更新します。 |
| `task build` | 🐳 ローカルのDockerfileからDockerイメージをビルドします。 |
| `task run` | 🚀 イメージをビルド後、古いコンテナを削除してからサーバーを起動します。 |
| `task run:compose` | 🚀 既存のビルドを使用し、Docker Compose経由でサーバーを起動します。 |

### 実行例
初回、あるいは最新に同期してサーバーを起動する場合:
```bash
task sync
task run
```

---

## 🖥️ Proxmox VE (LXC) へのインストール

Proxmox VE ホストのシェルで以下を実行すると、Debian 12 の LXC を作成し、`server/` の Dockerfile / docker-compose.yml をそのまま使ってサーバーを起動します。

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/nogikun/corekeeper-server/main/proxmox-install.sh)"
```

CT ID やストレージなどは環境変数で変更できます（`CTID` `CT_HOSTNAME` `STORAGE` `TEMPLATE_STORAGE` `BRIDGE` `DISK` `CORES` `MEMORY`）。
```bash
CTID=200 STORAGE=local-zfs MEMORY=8192 bash -c "$(curl -fsSL https://raw.githubusercontent.com/nogikun/corekeeper-server/main/proxmox-install.sh)"
```

- 接続用の Game ID: `pct exec <CTID> -- cat /opt/corekeeper-server/server/server-files/GameID.txt`
- 設定変更: CT 内の `/opt/corekeeper-server/server/core.env` を編集し `docker compose up -d`
- ゲーム本体の更新: `pct exec <CTID> -- docker restart core-keeper-dedicated`（起動時に自動更新されます）
- リポジトリ更新の反映:
  ```bash
  pct exec <CTID> -- bash -c 'cd /opt/corekeeper-server && git pull && cd server && docker build -t escaping/core-keeper-dedicated:latest . && docker compose up -d'
  ```

> [!WARNING]
> リポジトリは Public 前提です。`server/core.env` に `PASSWORD` や `DISCORD_WEBHOOK_URL` を書いてコミットしないでください（CT 内でのみ編集してください）。
