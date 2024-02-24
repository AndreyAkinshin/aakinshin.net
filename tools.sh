#!/usr/bin/env sh

dotnet run --project tools/Entry/Entry.csproj --configuration Release --verbosity quiet -- "$@"