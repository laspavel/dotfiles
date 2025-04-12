#!/bin/bash

# Установка Python 3.7 на RHEL системы.

set -euo pipefail

PYTHON_VERSION="3.7.9"
INSTALL_DIR="/opt"
ARCHIVE="Python-${PYTHON_VERSION}.tgz"
SOURCE_URL="https://www.python.org/ftp/python/${PYTHON_VERSION}/${ARCHIVE}"
LOGFILE="/var/log/python_build_${PYTHON_VERSION}.log"

log() {
  echo "$(date +'%F %T') - $*" | tee -a "$LOGFILE"
}

log "Installing required packages..."
yum install -y gcc make wget zlib-devel bzip2-devel openssl-devel \
               ncurses-devel libffi-devel readline-devel sqlite-devel \
               xz-devel tk-devel

cd "$INSTALL_DIR"
log "Downloading Python ${PYTHON_VERSION}..."
wget -c "$SOURCE_URL"

log "Extracting archive..."
tar -xvzf "$ARCHIVE"

cd "Python-${PYTHON_VERSION}"

log "Configuring build..."
./configure --enable-optimizations >> "$LOGFILE" 2>&1

log "Compiling (this may take a while)..."
make -j"$(nproc)" >> "$LOGFILE" 2>&1

log "Installing with altinstall..."
make altinstall >> "$LOGFILE" 2>&1

log "Python ${PYTHON_VERSION} installed at: $(command -v python3.7 || echo 'Not found')"
