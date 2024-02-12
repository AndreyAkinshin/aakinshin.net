#!/usr/bin/env bash

if [ $# -ge 1 ]; then
  TARGET_DIR="$1"
else
  rm -rf ./bin/
  mkdir ./bin
  TARGET_DIR="./bin"
fi

HUGO_URL_BASE="https://github.com/gohugoio/hugo/releases/download"
TW_URL_BASE="https://github.com/tailwindlabs/tailwindcss/releases/download"

HUGO_VER="0.122.0"
TW_VER="3.4.1"

ARCH=$(arch)
HUGO_ARCH="$ARCH"
TW_ARCH="$ARCH"

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
  HUGO_URL="${HUGO_URL_BASE}/v${HUGO_VER}/hugo_${HUGO_VER}_darwin-universal.tar.gz"
  TW_URL="${TW_URL_BASE}/v${TW_VER}/tailwindcss-macos-${TW_ARCH}"
else
  HUGO_URL="${HUGO_URL_BASE}/v${HUGO_VER}/hugo_${HUGO_VER}_linux-${HUGO_ARCH}.tar.gz"
  TW_URL="${TW_URL_BASE}/v${TW_VER}/tailwindcss-linux-${TW_ARCH}"
fi

wget "$HUGO_URL" -O "$TARGET_DIR/hugo.tar.gz"
tar -xzvf "$TARGET_DIR/hugo.tar.gz" -C "$TARGET_DIR" hugo
wget "$TW_URL" -O "$TARGET_DIR/tailwind"

chmod +x "$TARGET_DIR/hugo"
chmod +x "$TARGET_DIR/tailwind"
