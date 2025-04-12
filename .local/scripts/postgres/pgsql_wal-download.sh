#!/bin/bash

# Синхронизация WAL журналов между основным и резервным хостом.

/usr/bin/rsync -v -r --delete-before srv-db-p01a://var/lib/pgsql/wal_archive/ /var/lib/pgsql/p01a-wal_archive
chown postgres:postgres -R /var/lib/pgsql/p01a-wal_archive
