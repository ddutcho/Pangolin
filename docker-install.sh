#!/bin/bash

set -e

echo "[*] Aggiornamento pacchetti..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release

echo "[*] Aggiunta della chiave GPG ufficiale di Docker..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "[*] Aggiunta del repository Docker alla lista delle sorgenti APT..."
ARCH=$(dpkg --print-architecture)
DISTRO=$(lsb_release -cs)
echo \
  "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${DISTRO} stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "[*] Aggiornamento pacchetti e installazione Docker..."
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "[*] Abilitazione e avvio del servizio Docker..."
sudo systemctl enable docker
sudo systemctl start docker

echo "[*] Aggiunta dell'utente corrente al gruppo 'docker' (effettivo dopo il logout/login)..."
sudo usermod -aG docker "$USER"

echo "[✓] Docker installato correttamente. Riavvia la sessione per usare Docker senza 'sudo'."
