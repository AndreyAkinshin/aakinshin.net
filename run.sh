#!/usr/bin/env sh

cd hugo || exit
../bin/tailwind -i ./assets/css/main-tailwindcss.css -o ./assets/css/main.css
../bin/hugo server --port 1313 --liveReloadPort 1313 --forceSyncStatic --gc --watch "$@"
cd ..