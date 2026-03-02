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
