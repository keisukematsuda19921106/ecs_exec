# ECS Execインタラクティブスクリプト

このスクリプトは、[ECS Exec](https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/ecs-exec.html)を対話的に実行するためのツールです。対話的なインターフェースからECSクラスター、タスク、コンテナを選択し、コンテナ内でコマンドを実行することが可能です。

## 前提条件

- [ECS Execの前提条件](https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/ecs-exec.html#ecs-exec-prerequisites)を満たしていること
- ECSサービス/タスクにてECS Execが有効化されていること
- スクリプト実行端末にjqがインストールされていること

## 動作フロー

- AWSプロファイルの対話的選択
- ECSクラスターの一覧表示と選択
- タスクの一覧表示と選択（タスク定義とステータスを含む）
- コンテナの一覧表示と選択
- カスタムコマンドの実行（デフォルト: /bin/sh）

## 使用方法

### 1. スクリプトを実行可能にします：

```bash
chmod +x ecs-exec.sh
```

### 2. スクリプトを実行します：

```bash
./ecs-exec.sh
```

### 3. 画面の指示に従って以下を選択します：

- AWSプロファイル（オプション）
- ECSクラスター
- タスク
- コンテナ
- 実行するコマンド