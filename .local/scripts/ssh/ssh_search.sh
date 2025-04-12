#!/bin/bash

# Поиск доступных хостов в SSH окружении

ssh_search() {
    awk '
    BEGIN {
        host = "";
        hostname = "";
        user = "";
        port = "";
        identityfile = "";
    }
    # Если встречаем Host, записываем предыдущий блок данных и начинаем новый
    /^[[:space:]]*Host[[:space:]]+/ {
        if (host != "") {
            print host, (hostname ? hostname : "-"), (user ? user : "-"), (port ? port : "-"), (identityfile ? identityfile : "-");
        }
        host = $2;
        hostname = "";
        user = "";
        port = "";
        identityfile = "";
    }
    /^[[:space:]]*Hostname[[:space:]]+/ { hostname = $2 }
    /^[[:space:]]*User[[:space:]]+/ { user = $2 }
    /^[[:space:]]*Port[[:space:]]+/ { port = $2 }
    /^[[:space:]]*IdentityFile[[:space:]]+/ { 
        identityfile = (identityfile ? identityfile " " $2 : $2);
    }
    # В конце файла напечатаем последний обработанный блок
    END {
        if (host != "") {
            print host, (hostname ? hostname : "-"), (user ? user : "-"), (port ? port : "-"), (identityfile ? identityfile : "-");
        }
    }' ~/.ssh/config ~/.ssh/config.d/* 2>/dev/null | grep -i "$1" | column -t
}

ssh_search $@