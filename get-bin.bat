rmdir /s /q bin
mkdir bin

powershell -Command "(New-Object Net.WebClient).DownloadFile('https://github.com/AndreyAkinshin/hugo/releases/download/v0.102.3-patched/hugo-windows.exe', 'bin/hugo.exe')"
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://github.com/tailwindlabs/tailwindcss/releases/download/v3.2.4/tailwindcss-windows-x64.exe', 'bin/tailwind.exe')"