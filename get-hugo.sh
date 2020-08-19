#!/usr/bin/env sh

rm -rf ./bin/

wget https://raw.githubusercontent.com/AndreyAkinshin/hugo/v0.74.3-patched/bin/hugo-linux -P ./bin/

chmod +x ./bin/hugo-linux
