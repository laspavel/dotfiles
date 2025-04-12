#!/bin/bash

# Включение HW виртуализации для ВМ VirtualBox

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <vm_name>"
    exit 1
fi

VmName="$1"
VBoxManage modifyvm $VmName --nested-hw-virt on