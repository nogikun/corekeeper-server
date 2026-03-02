# Core Keeper 専用サーバー (Core Keeper Dedicated Server)

![corekeeper](https://user-images.githubusercontent.com/136487/168213246-7f561105-136e-47fa-abd9-fac1c97ca48d.png)

1～8人のプレイヤーで楽しめる採掘サンドボックスアドベンチャーで、クリーチャー、遺物、資源に満ちた終わりなき洞窟を探索しよう。採掘、建築、戦闘、クラフト、農業を行い、古代のコアの謎を解き明かしてください。[SteamストアでCore Keeperを入手する](https://store.steampowered.com/app/1621690/Core_Keeper/)

[![Docker Image CI](https://github.com/escapingnetwork/core-keeper-dedicated/actions/workflows/docker-image.yml/badge.svg?branch=main)](https://github.com/escapingnetwork/core-keeper-dedicated/actions/workflows/docker-image.yml)

## サポートされているタグと各 `Dockerfile` へのリンク
-	[`latest` (*Dockerfile*)](./Dockerfile)

## 実行方法

### ARM ベースの設定

このイメージには現在、以下のデバイス向けの Box64 ビルドバリアントが含まれています：

- Generic [generic]
- Raspberry Pi 3 [rpi3]
- Raspberry Pi 4 [rpi4-pre3]
- Raspberry Pi 5 (4K page size) [rpi5]
- Raspberry Pi 5 (16K page size) [rpi5_16k]
- M1 (M-Series) Mac [m1]
- ADLink Ampere Altra (Oracle ARM CPUs) [adlink]

デフォルトでは `generic` が設定されています。別のものを使用したい場合は、`core.env` ファイル内の環境変数 `ARM64_DEVICE` を変更してください。

### ボリューム

サーバーを実行したい場所に2つのディレクトリを作成します：

- `server-data`: 毎回再起動しても設定を保持したい場合は必須です
- `server-files`: オプションです。アプリケーションのすべてのファイルが含まれます

次に、以下の例にある `/host/path/to/server-data` や `/host/path/to/server-files` を、作成したフォルダのパスに合わせて変更してください。

### Docker CLI の使用:

```bash
docker run -d \
  --name core-keeper-dedicated \
  -e WORLD_NAME="Core Keeper Server" \
  -e MAX_PLAYERS=5 \
  -v /host/path/to/server-data:/home/steam/core-keeper-data \
  -v /host/path/to/server-files:/home/steam/core-keeper-dedicated \
  escaping/core-keeper-dedicated:latest
```

### Docker Compose の使用
以下の内容で [`docker-compose.yml`](./docker-compose-example/docker-compose.yml) を作成します：

```yml
services:
  core-keeper:
    image: escaping/core-keeper-dedicated:latest
    container_name: core-keeper-dedicated
    restart: unless-stopped
    stop_grace_period: 2m
    # ポートはダイレクト接続モードを使用する場合にのみ必要です
    # ports:
    #   - "$SERVER_PORT:$SERVER_PORT/udp"
    volumes:
      - /host/path/to/server-files:/home/steam/core-keeper-dedicated
      - /host/path/to/server-data:/home/steam/core-keeper-data
    env_file:
      - path: core.env
        required: false
```

`core.env` ファイルを作成し、専用サーバー用に希望する環境変数を上書きします。設定の参照項目をご覧ください。例：
```env
ARM64_DEVICE=rpi5
MAX_PLAYERS=3
```

ファイルが含まれているフォルダで `docker compose up -d` を実行します。

実行可能ファイルの隣に、ゲームIDを含む `GameID.txt` ファイルが作成されます。表示されない場合は、docker のログ (`docker logs core-keeper-dedicated` または `docker compose logs`) でエラーを確認できます。

ゲームIDを表示するには、以下を実行します：
`docker exec -it core-keeper-dedicated cat /home/steam/core-keeper-dedicated/GameID.txt`

## 設定

以下の引数を使用して、サーバーの動作をデフォルト値からカスタマイズできます。

| 引数 | デフォルト | 説明 |
| :---:   | :---: | :---: |
| PUID | 1000 | コンテナがファイルの所有権とアクセス許可に使用する、ホスト上のユーザーID。 |
| PGID | 1000 | コンテナがファイルの所有権とアクセス許可に使用する、ホスト上のグループID。 |
| ARM64_DEVICE | generic | Box64 ビルドバリアント。`generic`、`rpi5`、`m1`、`adlink` を指定できます。 |
| USE_DEPOT_DOWNLOADER | false | steamcmd の代わりに Depot downloader を使用します。32ビットと互換性のないシステムで役立ちます。 |
| WORLD_INDEX | 0 | 使用するワールドインデックス。 |
| WORLD_NAME | "Core Keeper Server" | サーバーに使用する名前。 |
| WORLD_SEED | "" | 新しいワールドに使用するシード値。ランダムなシードを生成するには "" を設定します。 |
| HASHED_WORLD_SEED | "" | 新しいワールドに使用するハッシュ化されたシード値（v1.1で追加）。ランダムなシードを生成するには "" を設定します。 |
| WORLD_MODE | 0 | ワールドのワールドモードを設定します。Normal (0)、Hard (1)、Creative (2)、Casual (4) が設定可能です。 |
| SEASON | デフォルトなし | None (0)、Easter (1)、Halloween (2)、Christmas (3)、Valentine (4)、Anniversary (5)、CherryBlossom (6)、LunarNewYear(7) のいずれかを設定して、現在のシーズンを上書きします。<br/>**実際の日付のシーズンを使用したい場合は、この環境変数を設定しないでください。** |
| GAME_ID | "" | サーバーに使用する Game ID。15文字以上、28文字以内の英数字である必要があります。空または無効な場合は、起動時に新しいIDが生成されます。 |
| MAX_PLAYERS | 10 | サーバーへの接続を許可する最大プレイヤー数。 |
| SERVER_IP | デフォルトなし | ポートが設定されている場合にのみ使用されます。サーバーがバインドするアドレスを設定します。ipv4 および ipv6 アドレスをサポートします。設定されていない場合はデフォルト値の 0.0.0.0 が使用され、任意の内部IPからの接続を受け入れます。 |
| SERVER_PORT | デフォルトなし | ダイレクト接続モードに使用されるポート。**これに値を設定すると、サーバーの動作が変更されます！** [ネットワークモード](#ネットワークモード)をご覧ください。 |
| PASSWORD | デフォルトなし | ダイレクト接続を使用して参加しようとする際にプレイヤーが使用すべきパスワード。パスワードの最大長は28文字です。省略または無効な場合は、ランダムなパスワードが生成されます。|
| ACTIVATE_CONTENT | "" | v1.1 より前に作成されたワールドのバイオームを有効にするためのカンマ区切りリスト。有効な値は `GiantCicadaBossDungeon`、`NatureBiomeCicadas`、`GuaranteedOases`、`BiomeStatues`、`AbioticFactor` です。一度有効にすると、無効にすることはできません！ |
| ACTIVATE_ALL_CONTENT | false | `ACTIVATE_CONTENT` と同じですが、すべてのコンテンツバンドルを有効にします。 |
| ALLOW_ONLY_PLATFORM | デフォルトなし | 指定されたプラットフォームのプレイヤーのみを許可します。設定されていない場合は、すべてのプラットフォームが許可されます。-port も設定してダイレクト接続を有効にしない限り効果はありません。Steam (1)、Epic (2)、Microsoft (3)、GOG (4) が設定可能です。 |
| DISCORD_WEBHOOK_URL | "" | Webhook URL (チャンネルの編集 > 連携 > Webhook を作成)。 |
| DISCORD_PLAYER_JOIN_ENABLED | true | プレイヤー参加時のメッセージを有効/無効にします。 |
| DISCORD_PLAYER_JOIN_MESSAGE | `"$${char_name} ($${steamid}) has joined the server."` | 埋め込みメッセージ。 |
| DISCORD_PLAYER_JOIN_TITLE | "Player Joined" | 埋め込みタイトル。 |
| DISCORD_PLAYER_JOIN_COLOR | "47456" | 埋め込みカラー。 |
| DISCORD_PLAYER_LEAVE_ENABLED | true | プレイヤー退出時のメッセージを有効/無効にします。 |
| DISCORD_PLAYER_LEAVE_MESSAGE | `"$${char_name} ($${steamid}) has disconnected. Reason: $${reason}."` | 埋め込みメッセージ。 |
| DISCORD_PLAYER_LEAVE_TITLE | "Player Left" | 埋め込みタイトル。 |
| DISCORD_PLAYER_LEAVE_COLOR | "11477760" | 埋め込みカラー。 |
| DISCORD_SERVER_START_ENABLED | true | サーバー起動時のメッセージを有効/無効にします。 |
| DISCORD_SERVER_START_MESSAGE | `"**World:** $${world_name}\n**GameID:** $${gameid}"` | 埋め込みメッセージ。使用可能な変数は `world_name`, `gameid`, (以降はダイレクト接続モードのみ) `allowed_platforms`, `public_ip`, `port`, `password`, `join_string` です。 |
| DISCORD_SERVER_START_TITLE | "Server Started" | 埋め込みタイトル。 |
| DISCORD_SERVER_START_COLOR | "2013440" | 埋め込みカラー。 |
| DISCORD_SERVER_STOP_ENABLED | true | サーバー停止時のメッセージを有効/無効にします。 |
| DISCORD_SERVER_STOP_MESSAGE | "" | 埋め込みメッセージ。 |
| DISCORD_SERVER_STOP_TITLE | "Server Stopped" | 埋め込みタイトル。 |
| DISCORD_SERVER_STOP_COLOR | "12779520" | 埋め込みカラー。 |
| MODS_ENABLED | false | MODサポートを有効/無効にします。 |
| MODIO_API_KEY | "" | mod.io API キー |
| MODIO_API_URL | "" | mod.io API パス |
| MODS | "" | インストールする MOD のリスト |

## MOD サポート

このコンテナは、[mod.io](https://mod.io/g/corekeeper) からの MOD の自動インストールをサポートしています。

1. [mod.io/me/access](https://mod.io/me/access) から mod.io API キーを取得します。
    - キーと一緒に生成される API パスが必要です（例：https://u-*.modapi.io/v1）
2. `core.env` ファイル（または `docker-compose.yml`）に必要な環境変数を設定します。
  - `MODS_ENABLED=true`
  - `MODIO_API_KEY=your_api_key`
  - `MODIO_API_URL=your_api_url`
  - `MODS=mod1,mod2` （以下を参照）

### インストールする MOD の指定

> [!WARNING]
> クライアント専用の MOD をインストールすると、サーバーが起動しなくなる可能性があります。クライアント専用の MOD はインストールしないでください（サーバー上では機能しません）。

> [!IMPORTANT]
> MOD の依存関係は自動的にはインストールされません。インストールしたい各 MOD の依存関係を確認し、それらをリストに追加する必要があります。

インストールしたい各 MOD について、mod.io から MOD の文字列 ID を取得する必要があります。最も簡単な方法は、URL から取得することです。

例えば、[CoreLib](https://mod.io/g/corekeeper/m/core-lib) の URL (`https://mod.io/g/corekeeper/m/core-lib`) を見ると、`core-lib` を使用します。

カンマ区切りのリストとして MOD を指定し、オプションでバージョンを提供できます：

```sh
# フォーマット: <mod_id>[:<version>], ...
MODS=core-lib,coreliblocalization,corelibrewiredextension,ck-qol
```

特定のバージョンを使用する例：

```sh
MODS=core-lib,coreliblocalization,corelibrewiredextension:3.0.1,ck-qol:1.9.4
```

- `version` が指定されていない場合、最新バージョンがインストールされます。
- コンテナが起動するたびに MOD は再インストールされるため、MOD を最新バージョンに更新するには、単にコンテナを再起動してください。

## ネットワークモード

現在、Core Keeper は2つのネットワークモードをサポートしています：SDR (Steam Datagram Relay) とダイレクト接続です。

### SDR (Steam Datagram Relay)
このモードでは、サーバーは [Valveの仮想ネットワーク](https://partner.steamgames.com/doc/features/multiplayer/steamdatagramrelay) を使用して、 Steamの リレーインフラを経由してトラフィックをルーティングします。プレイヤーはサーバーのIPアドレスに直接接続するのではなく、すべての通信は Steam が管理する安全なリレーノードを経由します。これにより、サーバーの実際のIPが隠蔽され、DDoS攻撃から保護され、NATトラバーサルが改善されます。

このリレーシステムのおかげで、サーバー管理者はルーターやファイアウォールのポートを開放する必要がありません。Steam へのアウトバウンド接続が許可されていれば、サーバーは確実にクライアントと通信できます。

### ダイレクト接続
ダイレクト接続モードでは、プレイヤーは Steam のリレーネットワークを経由せずに、サーバーのパブリックIPアドレスに直接接続します。これにより、レイテンシが低くなり通信がより直接的になる場合がありますが、インターネットからサーバーにアクセスできる必要があります。

サーバー管理者は、着信接続を許可するために、ルーターやファイアウォールで必要なポートを開放およびフォワードする必要があります。SDRとは異なり、このモードではサーバーのIPアドレスがクライアントに公開され、接続の問題や攻撃に対してより脆弱になる可能性があります。

> [!IMPORTANT]<br>
> SERVER_PORT 環境変数がサーバーのネットワークモードを決定します。<br>
> SDRを使用する場合は空のままにしてください（ポートフォワーディングは不要です）。<br>
> 値を設定するとダイレクト接続に切り替わり、ポートの開放とフォワーディングが必要になります。<br>
> 特にダイレクト接続を希望する場合にのみ、これを設定してください。

### コントリビューター
<a href="https://github.com/escapingnetwork/core-keeper-dedicated/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=escapingnetwork/core-keeper-dedicated" />
</a>

[contrib.rocks](https://contrib.rocks) で作成。
