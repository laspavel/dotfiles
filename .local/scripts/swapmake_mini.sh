#!/bin/bash

SWAPFILE=/swapfile
SWAPSIZE=8

calculat() { awk "BEGIN{ print $* }" ;}

SWAPSIZEBYTE=`calculat $SWAPSIZE*1048576`
dd if=/dev/zero of=$SWAPFILE bs=1024 count=$SWAPSIZEBYTE
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
swapon --show

# If required add line in /etc/fstab:
# /swapfile swap swap defaults 0 0
