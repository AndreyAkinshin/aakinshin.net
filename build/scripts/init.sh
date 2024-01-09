#!/usr/bin/env bash

if [ $# -ge 1 ]; then
  TARGET_DIR="$1"
else
  rm -rf ./bin/
  mkdir ./bin
  TARGET_DIR="./bin"
fi

HUGO_VER="v0.102.3-patched2"
TW_VER="v3.3.5"

ARCH=$(arch)

if [ $ARCH == "x86_64" ]; then
  ARCH="x64"
fi
if [ $ARCH == "aarch64" ]; then
  ARCH="arm64"
fi

if [ "$(uname)" == "Darwin" ]
then
  HUGO_URL="https://github.com/AndreyAkinshin/hugo/releases/download/${HUGO_VER}/hugo-macos"
  TW_URL="https://github.com/tailwindlabs/tailwindcss/releases/download/${TW_VER}/tailwindcss-macos-${ARCH}"
else
  HUGO_URL="https://github.com/AndreyAkinshin/hugo/releases/download/${HUGO_VER}/hugo-linux-${ARCH}"
  TW_URL="https://github.com/tailwindlabs/tailwindcss/releases/download/${TW_VER}/tailwindcss-linux-${ARCH}"
fi

wget $HUGO_URL -O $TARGET_DIR/hugo
wget $TW_URL -O $TARGET_DIR/tailwind

chmod +x $TARGET_DIR/hugo
chmod +x $TARGET_DIR/tailwind