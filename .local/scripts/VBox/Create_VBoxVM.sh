#!/bin/bash

# Создание ВМ VirtualBox

OSTYPE="Debian_64"
VmName="VM1"
MEM=2048
CPU=2
DISK=25600

# Create a new VM
VBoxManage createvm --name "$VmName" --ostype "$OSTYPE" --register

# Set memory and CPU
VBoxManage modifyvm "$VmName" --memory $MEM --cpus $CPU

# Set network to Bridged Adapter using wlp0s20f3
VBoxManage modifyvm "$VmName" --nic1 bridged --bridgeadapter1 wlp0s20f3

# Create a virtual hard disk
VBoxManage createhd --filename ~/VirtualBox\ VMs/$VmName/$VmName.vdi --size $DISK

# Add a SATA controller and attach the disk
VBoxManage storagectl "$VmName" --name "SATA Controller" --add sata --controller IntelAHCI
VBoxManage storageattach "$VmName" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium ~/VirtualBox\ VMs/$VmName/$VmName.vdi

# Add EFI
VBoxManage modifyvm "$VmName" --firmware efi

# Add an IDE controller and attach the ISO file as LiveCD
VBoxManage storagectl "$VmName" --name "IDE Controller" --add ide
VBoxManage storageattach "$VmName" --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium /home/laspavel/ISOs/SV_debian-12.5.0-amd64-DVD-1.iso

# Enable I/O APIC
VBoxManage modifyvm "$VmName" --ioapic on

# Set boot order to boot from DVD first
VBoxManage modifyvm "$VmName" --boot1 dvd

# Set video memory to 32 MB and video controller to VBoxSVGA
VBoxManage modifyvm "$VmName" --vram 32 --graphicscontroller vmsvga
