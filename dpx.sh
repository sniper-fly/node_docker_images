#!/bin/bash

dpx() {
  local port_mapping=""
  local port_option=""
  # ポート指定オプションの処理
  if [[ "$1" == "-p" && -n "$2" ]]; then
    port_option="-p"
    port_mapping="$2:$2"
    shift 2
  fi

  # 開始ディレクトリ（カレントディレクトリ）
  local DIR=$(pwd)

  # 探索の上限ディレクトリ
  local ROOT_DIR=$HOME

  # 現在のディレクトリが ROOT_DIR より下の階層かどうかをチェック
  if [[ "$DIR" != "$ROOT_DIR"* ]]; then
    echo "Error: Current directory is not under $ROOT_DIR"
    return 1
  fi

  # .tool-versions を探すループ
  local TOOL_VERSIONS_FILE=""
  while [[ "$DIR" == "$ROOT_DIR"* ]]; do
    if [[ -f "$DIR/.tool-versions" ]]; then
      TOOL_VERSIONS_FILE="$DIR/.tool-versions"
      break
    fi
    # ルートまで来た場合は終了
    if [[ "$DIR" == "$ROOT_DIR" ]]; then
      break
    fi
    DIR=$(dirname "$DIR") # 親ディレクトリへ移動
  done

  # .tool-versions が見つからなかった場合
  if [[ -z "$TOOL_VERSIONS_FILE" ]]; then
    echo "Error: .tool-versions not found under $ROOT_DIR"
    return 1
  fi

  # echo "== Using .tool-versions from: $TOOL_VERSIONS_FILE =="

  # .tool-versions から nodejs のバージョンを取得
  NODE_VERSION=$(grep '^nodejs ' "$TOOL_VERSIONS_FILE" | awk '{print $2}')

  if [[ -z "$NODE_VERSION" ]]; then
    echo "Error: .tool-versions に nodejs のバージョンが記載されていません"
    return 1
  fi

  # echo "== Detected Node.js version: $NODE_VERSION =="

  # バージョンに応じた処理
  if [[ "$NODE_VERSION" =~ ^18\. ]]; then
    docker run --rm -it \
      -v "$PWD":/app -w /app \
      --user $(id -u):$(id -g) \
      $port_option $port_mapping \
      node:18-bullseye npx "$@"
  else
    docker run --rm -it \
      -v "$PWD":/app -w /app \
      $port_option $port_mapping \
      -v npx-cache-node23:/home/node/.npm \
      zafu/node23-tsx:1.2 npx "$@"
  fi
}
