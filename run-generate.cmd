cd web\_import\Talks
dotnet run
xcopy "_generated" "../../_generated" /i /s /y
cd ..\Publications
dotnet run
xcopy "_generated" "../../_generated" /i /s /y
cd ..\..\..\