#!/bin/bash

# Установка инструментов K8S

INSTALL_PATH=/usr/local/bin
KUBECTL=1.18.1
KUBECTX=0.8.0
K9S=0.19.1

# Install `kubectl`
sudo curl -o "${INSTALL_PATH}/kubectl" -LO "https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL}/bin/linux/amd64/kubectl" && \
sudo chmod +x "${INSTALL_PATH}/kubectl"
# Install `kubectx` and `kubens`
curl -LO "https://github.com/ahmetb/kubectx/archive/v${KUBECTX}.zip" && \
unzip -a "v${KUBECTX}.zip" && \
sudo mv kubectx-${KUBECTX}/kubectx "${INSTALL_PATH}/kubectx" && \
sudo mv kubectx-${KUBECTX}/kubens "${INSTALL_PATH}/kubens" && \
rm -rf "kubectx-${KUBECTX}" "v${KUBECTX}.zip"
# Install `k9s`
curl -L "https://github.com/derailed/k9s/releases/download/v${K9S}/k9s_Linux_x86_64.tar.gz" | tar xvz && \
sudo mv k9s "${INSTALL_PATH}"/k9s && \
rm -f README.md LICENSE
