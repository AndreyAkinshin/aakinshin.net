#!/usr/bin/env sh

./tools.sh gen

cd hugo || exit
echo "Running tailwind..."
../bin/tailwind -i ./assets/css/main-tailwindcss.css -o ./assets/css/main.css
echo "Running hugo..."
../bin/hugo --minify

cp ./public/posts/index.xml ./public/rss.xml
cp ./public/posts/index.xml ./public/en/rss.xml
cp ./public/ru/posts/index.xml ./public/ru/rss.xml

cd ..