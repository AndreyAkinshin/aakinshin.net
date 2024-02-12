#!/usr/bin/env bash

if [ $# -ge 1 ]; then
  TARGET_DIR="$1"
else
  rm -rf ./bin/
  mkdir ./bin
  TARGET_DIR="./bin"
fi

HUGO_VER="0.122.0"
TW_VER="v3.3.5"

ARCH=$(arch)

if [ "$ARCH" == "x86_64" ]; then
  HUGO_ARCH="amd64"
  TW_ARCH="x64"
fi
if [ "$ARCH" == "aarch64" ]; then
  HUGO_ARCH="arm64"
  TW_ARCH="arm64"
fi

if [ "$(uname)" == "Darwin" ]
then
  HUGO_URL="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VER}/hugo_${HUGO_VER}_darwin-universal.tar.gz"
  TW_URL="https://github.com/tailwindlabs/tailwindcss/releases/download/${TW_VER}/tailwindcss-macos-${TW_ARCH}"
else
  HUGO_URL="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VER}/hugo_${HUGO_VER}_linux-${HUGO_ARCH}.tar.gz"
  TW_URL="https://github.com/tailwindlabs/tailwindcss/releases/download/${TW_VER}/tailwindcss-linux-${TW_ARCH}"
fi

wget "$HUGO_URL" -O "$TARGET_DIR/hugo.tar.gz"
tar -xzvf "$TARGET_DIR/hugo.tar.gz" -C "$TARGET_DIR" hugo
wget "$TW_URL" -O "$TARGET_DIR/tailwind"

chmod +x "$TARGET_DIR/hugo"
chmod +x "$TARGET_DIR/tailwind"
