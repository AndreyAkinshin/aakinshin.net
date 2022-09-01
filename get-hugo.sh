#!/usr/bin/env bash

rm -rf ./bin/
mkdir ./bin

if [ "$(uname)" == "Darwin" ]
then
  wget https://github.com/AndreyAkinshin/hugo/releases/download/v0.102.3-patched/hugo-macos -O ./bin/hugo
else
  wget https://github.com/AndreyAkinshin/hugo/releases/download/v0.102.3-patched/hugo-linux -O ./bin/hugo
fi

chmod +x ./bin/hugo
