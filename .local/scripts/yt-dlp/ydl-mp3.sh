#!/bin/bash

# Загрузка MP3 из Youtube

# Проверка на наличие аргумента
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <Link>"
    exit 1
fi

LINK=$1
yt-dlp -f "bestaudio" --extract-audio --audio-format mp3 $LINK
