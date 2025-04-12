#!/bin/bash

# Создание бинарного и дамп архива БД из docker инстанса postgres с уведомлением в Телеграмм в случае ошибки.

if [ -f .env ]
then
  export $(cat .env | sed 's/#.*//g' | xargs)
fi

BACKUP_DIR=/backup/$DOCKER_CONTAINER
DAYSTORETAINBACKUP=2

function SendToTelegram() {
  chat="$1"
  message="$2"
  token='xxxxxxxxx:xxxxxxxxxxxxxxxxxxxxxxxxxxxx'
  curl -s --header 'Content-Type: application/json' --request 'POST' --data "{\"chat_id\":\"${chat}\",\"text\":\"${message}\"}" "https://api.telegram.org/bot${token}/sendMessage"
}

let ResultCode=0
TIMESTAMP=`date +%F-%H%M`
BACKUP_NAME="pgsql-$TIMESTAMP"

mkdir -p $BACKUP_DIR/$BACKUP_NAME
let ResultCode=ResultCode+$?

cd $BACKUP_DIR/$BACKUP_NAME
let ResultCode=ResultCode+$?

# Binary
docker exec $DOCKER_CONTAINER bash -c "cd $BACKUP_DIR && export PGPASSWORD=$POSTGRES_PASSWORD && pg_basebackup -U $POSTGRES_USER  -R -Ft -z -D $BACKUP_DIR/$BACKUP_NAME"
let ResultCode=ResultCode+$?

# Dump
docker exec $DOCKER_CONTAINER bash -c "cd $BACKUP_DIR && export PGPASSWORD=$POSTGRES_PASSWORD && pg_dump -U $POSTGRES_USER  $POSTGRES_DB | gzip  > $BACKUP_DIR/$BACKUP_NAME/$POSTGRES_DB.sql.gz"
let ResultCode=ResultCode+$?

if [[ $ResultCode -gt 0 ]];then
  sendtotelegram "xxxxxxxxxx" "$DOCKER_CONTAINER: PGSQL backup failed. ResultCode: $ResultCode"
  exit 1;
fi;

find $BACKUP_DIR/pgsql* -mtime +$DAYSTORETAINBACKUP -exec rm {} \;
find $BACKUP_DIR/pgsql* -mtime +$DAYSTORETAINBACKUP -type d -exec rmdir {} \;
chmod -Rf 644 $BACKUP_DIR/pgsql-*
