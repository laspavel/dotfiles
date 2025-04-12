#!/bin/bash

# Простое резервное копирование баз данных (дампом) с удалением старых копий.

POSTGRES_USER=postgres
POSTGRES_PASSWORD=xxxxxxxxxx

TARGETDIR=/backup/Dump
DAYD=4

DATADIR=$TARGETDIR/`date +%Y-%m-%d`
STATUS='/tmp/pgbackup_last_status'

let ResultCode=0

if [ ! -d "$DATADIR" ]; then
    mkdir -p $DATADIR
fi

dblist=`su - postgres  -c 'psql -A -q -t -c "select datname from pg_database"'`
for db in $dblist; do
    echo "Dumping $db ... "
    export PGPASSWORD=$POSTGRES_PASSWORD && pg_dump -Fd $db -j $(nproc) -h srv-db-p01a -U $POSTGRES_USER -f $DATADIR/$db
    let ResultCode=ResultCode+$?
done

export PGPASSWORD=$POSTGRES_PASSWORD && pg_dumpall -c -g -h srv-db-p01a -U $POSTGRES_USER > $DATADIR/_globals.sql
let ResultCode=ResultCode+$?

if [ "$ResultCode" -ne "0" ]; then
  echo "1" > $STATUS
  exit 1
else 
  echo "0" > $STATUS
  find $TARGETDIR -name '*.gz' -type f -atime +$DAYD -delete 
  find $TARGETDIR -type d -empty -exec rmdir {} \;
  exit 0;
fi;
