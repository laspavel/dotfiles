#!/bin/bash

# Загрузка MP4 из Youtube

# Проверка на наличие аргумента
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <Link>"
    exit 1
fi

LINK=$1
yt-dlp -f "bestvideo+bestaudio/best" --merge-output-format mp4 $LINK
