#!/bin/bash

# Удаление старых скриншотов

find "$HOME/Pictures/Screenshots" -type f -mtime +3 -delete
