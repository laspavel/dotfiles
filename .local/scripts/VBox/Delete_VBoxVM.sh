#!/bin/bash

# Удаление ВМ VirtualBox

VmName="VM1"

# Power off the VM if it's running
VBoxManage controlvm "$VmName" poweroff
sleep 3
# Unregister and delete the VM and all associated files
VBoxManage unregistervm "$VmName" --delete
