#!/bin/bash

# Удаляет базы данных из инстанса согласно переданного в аргументе файла со списком. (bash pgsql_drop_list_databases.sh DatabaseDropList.txt)

DATAFILE=$1
for db in `cat $DATAFILE`;
do
   psql -c "DROP DATABASE IF EXISTS \"$db\";"
   echo "DROP DATABASE $db"
done