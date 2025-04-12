#!/bin/bash

# Создание бинарного и дамп архива БД из localhost инстанса postgres с уведомлением в Телеграмм в случае ошибки.

POSTGRES_USER=postgres
POSTGRES_PASSWORD=xxxxxxxxxx

BACKUP_DIR="/backup"
DAYD=4

TIMESTAMP=`date +%F-%H%M`
BACKUP_NAME="backup-pgsql-$TIMESTAMP"
STATUS='/tmp/pgbackup_last_status'

function SendToTelegram() {
  chat="$1"
  message="$2"
  # Bot token (BotFather)
  token='xxxxxxxxx:xxxxxxxxxxxxxxxxxxxxxxxxxxxx'
  curl -s --header 'Content-Type: application/json' --request 'POST' --data "{\"chat_id\":\"${chat}\",\"text\":\"${message}\"}" "https://api.telegram.org/bot${token}/sendMessage"
}

let ResultCode=0
if [ ! -d "$DATADIR" ]; then
    mkdir -p $DATADIR
    let ResultCode=ResultCode+$?
fi

cd $BACKUP_DIR
let ResultCode=ResultCode+$?

# For PGDump
cd $BACKUP_DIR && export PGPASSWORD=$POSTGRES_PASSWORD && pg_dumpall -h localhost -U $POSTGRES_USER | gzip > $BACKUP_DIR/$BACKUP_NAME.gz
let ResultCode=ResultCode+$?

# For Binary
cd $BACKUP_DIR && export PGPASSWORD=$POSTGRES_PASSWORD && sudo -u postgres pg_basebackup -U $POSTGRES_USER  -R -Ft -z -D $BACKUP_DIR/$BACKUP_NAME
let ResultCode=ResultCode+$?

if [ "$ResultCode" -ne "0" ]; then
  echo "1" > $STATUS
  exit 1
else
  echo "0" > $STATUS
  find $BACKUP_DIR -mtime +$DAYD -exec rm {} \;
  for dir in `find $BACKUP_DIR -type d -empty -mtime +$DAYD`; do rm -rf $dir; done
  chown postgres:postgres $BACKUP_DIR -R
  exit 0;
fi;