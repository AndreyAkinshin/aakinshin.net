#!/usr/bin/env sh

cd _utils/DataProcessor
dotnet run
cd ../..

./bin/hugo --minify "$@"

cp ./public/posts/index.xml ./public/rss.xml
cp ./public/posts/index.xml ./public/en/rss.xml
cp ./public/ru/posts/index.xml ./public/ru/rss.xml