#!/bin/bash

# Установка мультимедиа-кодеков на Fedora / RHEL / CentOS / Rocky / Alma Linux.

sudo dnf install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel
sudo dnf install lame\* --exclude=lame-devel
sudo dnf group upgrade --with-optional Multimedia

