#!/bin/bash

# Создание резервного окружения с удалением старых файлов.

/usr/bin/rsync -avztr -e 'ssh -i $HOME/.ssh/id_rsa' --delete --exclude-from files_rsync_on_res.exclude_pattern $HOME laspavel@laspavel-res2:/home/ > /tmp/rsync.log 2>&1
