rm -rf web/_generated
cd web/_import/Talks
dotnet run
cp -a _generated ../../
cd ../Publications
dotnet run
cp -a _generated ../../
cd ../OpenSource
dotnet run
cp -a _generated ../../
cd ../Media
dotnet run
cp -a _generated ../../
cd ../../../
