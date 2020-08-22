cd _utils\DataProcessor
dotnet run
cd ..\..

.\bin\hugo.exe --minify %*

copy .\public\posts\index.xml public\rss.xml /Y
copy .\public\posts\index.xml public\en\rss.xml /Y
copy .\public\ru\posts\index.xml public\ru\rss.xml /Y