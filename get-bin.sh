#!/usr/bin/env bash

rm -rf ./bin/
mkdir ./bin

ARCH=$(arch)

if [ $ARCH == "x86_64" ]; then
  ARCH="x64"
fi

if [ "$(uname)" == "Darwin" ]
then
  HUGO_URL="https://github.com/AndreyAkinshin/hugo/releases/download/v0.102.3-patched/hugo-macos"
  TW_URL="https://github.com/tailwindlabs/tailwindcss/releases/download/v3.2.4/tailwindcss-macos-${ARCH}"
else
  HUGO_URL="https://github.com/AndreyAkinshin/hugo/releases/download/v0.102.3-patched/hugo-linux"
  TW_URL="https://github.com/tailwindlabs/tailwindcss/releases/download/v3.2.4/tailwindcss-linux-${ARCH}"
fi

wget $HUGO_URL -O ./bin/hugo
wget $TW_URL -O ./bin/tailwind

chmod +x ./bin/hugo
chmod +x ./bin/tailwind