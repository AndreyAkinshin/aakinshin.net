#!/usr/bin/env bash

rm -rf ./bin/
mkdir ./bin

if [ "$(uname)" == "Darwin" ]
then
  wget https://raw.githubusercontent.com/AndreyAkinshin/hugo/v0.74.3-patched/bin/hugo-macos -O ./bin/hugo
else
  wget https://raw.githubusercontent.com/AndreyAkinshin/hugo/v0.74.3-patched/bin/hugo-linux -O ./bin/hugo
fi

chmod +x ./bin/hugo
