#!/usr/bin/env sh

if [ "$1" = "sym" ]; then
  # rm -f ./content
  # ln -s ./hugo/content/en ./content

  rm -f ./hugo/content/en/posts/drafts
  ln -s ~/Dropbox/Notes/Workbenches/Research/drafts ./hugo/content/en/posts/drafts

  # rm -f ./wip
  # ln -s ~/Dropbox/Notes/Workbenches/Research/drafts/wip ./wip

  rm -f ./hugo/static/pdf
  ln -s ~/Dropbox/Library ./hugo/static/pdf
elif [ "$1" = "unsym" ]; then
  rm -f ./content
  rm -f ./hugo/content/en/posts/drafts
  rm -f ./wip
  rm -f ./hugo/static/pdf
else
  dotnet run --project tools/Entry/Entry.csproj --configuration Release --verbosity quiet --property WarningLevel=0 -- "$@"
fi