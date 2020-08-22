rmdir /s /q bin
mkdir bin

powershell -Command "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/AndreyAkinshin/hugo/v0.74.3-patched/bin/hugo-windows.exe', 'bin/hugo.exe')"