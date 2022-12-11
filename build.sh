#!/usr/bin/env sh

cd _utils/DataProcessor
dotnet run
cd ../..

./bin/tailwind -i ./assets/css/main-tailwindcss.css -o ./assets/css/main.css
./bin/hugo --minify "$@"

cp ./public/posts/index.xml ./public/rss.xml
cp ./public/posts/index.xml ./public/en/rss.xml
cp ./public/ru/posts/index.xml ./public/ru/rss.xml