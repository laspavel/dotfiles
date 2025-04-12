#!/bin/bash

if [ -f .env ]
then
  export $(cat .env | sed 's/#.*//g' | xargs)
fi

BACKUP_DIR="/backup/pgsql"
DAYSTORETAINBACKUP=10

function sendtotelegram() {
chat="$1"
message="$2"
# Bot token
token='0000000000000000000000000000000000'
 curl -s --header 'Content-Type: application/json' --request 'POST' --data "{\"chat_id\":\"${chat}\",\"text\":\"${message}\"}" "https://api.telegram.org/bot${token}/sendMessage"
}

let ResultCode=0
TIMESTAMP=`date +%F-%H%M`
BACKUP_NAME="backup-pgsql-$TIMESTAMP"

mkdir -p $BACKUP_DIR
let ResultCode=ResultCode+$?

cd $BACKUP_DIR
let ResultCode=ResultCode+$?

# For PGDump
cd $BACKUP_DIR && export PGPASSWORD=$POSTGRES_PASSWORD && pg_dump -U $POSTGRES_USER $POSTGRES_DATABASE | gzip  > $BACKUP_DIR/$BACKUP_NAME.gz
let ResultCode=ResultCode+$? 
# For Binary
cd $BACKUP_DIR && export PGPASSWORD=$POSTGRES_PASSWORD && pg_basebackup -U $POSTGRES_USER  -R -Ft -z -D $BACKUP_DIR/$BACKUP_NAME
let ResultCode=ResultCode+$?

find $BACKUP_DIR -mtime +$DAYSTORETAINBACKUP -exec rm {} \;
let ResultCode=ResultCode+$?
find $BACKUP_DIR -mtime +$DAYSTORETAINBACKUP -type d -exec rmdir {} \;
let ResultCode=ResultCode+$?

if [[ $ResultCode -gt 0 ]];then
  sendtotelegram "99999999" "ALARM: Generate PGSQL backup failed. $ResultCode"
  exit 1;
fi;


