#!/bin/bash

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== ECS Execインタラクティブスクリプト ===${NC}"
echo -e "${YELLOW}AWS CLIとjqがインストールされている必要があります${NC}"
echo ""

# AWSプロファイルの選択（オプション）
if [ -f ~/.aws/credentials ]; then
  echo -e "${BLUE}利用可能なAWSプロファイル:${NC}"
  profiles=$(grep '^\[' ~/.aws/credentials | tr -d '[]')
  echo "$profiles"
  echo ""
  read -p "使用するAWSプロファイルを入力してください（デフォルトの場合は空欄）: " aws_profile

  if [ -n "$aws_profile" ]; then
    export AWS_PROFILE="$aws_profile"
    echo -e "${GREEN}プロファイル '$aws_profile' を使用します${NC}"
  else
    echo -e "${GREEN}デフォルトプロファイルを使用します${NC}"
  fi
  echo ""
fi

# クラスターの選択
echo -e "${BLUE}ECSクラスターを取得中...${NC}"
clusters=$(aws ecs list-clusters | jq -r '.clusterArns[] | split("/") | .[1]')

if [ -z "$clusters" ]; then
  echo -e "${YELLOW}クラスターが見つかりませんでした。${NC}"
  exit 1
fi

echo "利用可能なクラスター:"
i=1
for cluster in $clusters; do
  echo "$i) $cluster"
  i=$((i+1))
done

echo ""
read -p "クラスター番号を選択してください: " cluster_num

# 選択された番号からクラスター名を取得
selected_cluster=$(echo "$clusters" | sed -n "${cluster_num}p")
echo -e "${GREEN}選択されたクラスター: $selected_cluster${NC}"
echo ""

# タスクの選択
echo -e "${BLUE}タスクを取得中...${NC}"
tasks=$(aws ecs list-tasks --cluster "$selected_cluster" | jq -r '.taskArns[] | split("/") | .[2]')

if [ -z "$tasks" ]; then
  echo -e "${YELLOW}タスクが見つかりませんでした。${NC}"
  exit 1
fi

echo "利用可能なタスク:"
i=1
for task in $tasks; do
  # タスクの詳細情報を取得
  task_info=$(aws ecs describe-tasks --cluster "$selected_cluster" --tasks "$task" | jq -r '.tasks[0]')
  task_def=$(echo "$task_info" | jq -r '.taskDefinitionArn | split("/") | .[1]')
  status=$(echo "$task_info" | jq -r '.lastStatus')
  echo "$i) $task ($task_def) - $status"
  i=$((i+1))
done

echo ""
read -p "タスク番号を選択してください: " task_num

# 選択された番号からタスクIDを取得
selected_task=$(echo "$tasks" | sed -n "${task_num}p")
echo -e "${GREEN}選択されたタスク: $selected_task${NC}"
echo ""

# コンテナの選択
echo -e "${BLUE}コンテナを取得中...${NC}"
containers=$(aws ecs describe-tasks --cluster "$selected_cluster" --tasks "$selected_task" | jq -r '.tasks[0].containers[].name')

if [ -z "$containers" ]; then
  echo -e "${YELLOW}コンテナが見つかりませんでした。${NC}"
  exit 1
fi

echo "利用可能なコンテナ:"
i=1
for container in $containers; do
  echo "$i) $container"
  i=$((i+1))
done

echo ""
read -p "コンテナ番号を選択してください: " container_num

# 選択された番号からコンテナ名を取得
selected_container=$(echo "$containers" | sed -n "${container_num}p")
echo -e "${GREEN}選択されたコンテナ: $selected_container${NC}"
echo ""

# 実行するコマンドの入力
read -p "実行するコマンドを入力してください（デフォルト: /bin/sh）: " command
if [ -z "$command" ]; then
  command="/bin/sh"
fi

echo -e "${BLUE}以下のコマンドを実行します:${NC}"
echo "aws ecs execute-command --cluster $selected_cluster --task $selected_task --container $selected_container --command \"$command\" --interactive"
echo ""
read -p "実行しますか？ (y/n): " confirm

if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
  echo -e "${GREEN}コマンドを実行中...${NC}"
  aws ecs execute-command \
    --cluster "$selected_cluster" \
    --task "$selected_task" \
    --container "$selected_container" \
    --command "$command" \
    --interactive
else
  echo -e "${YELLOW}コマンドの実行をキャンセルしました${NC}"
fi