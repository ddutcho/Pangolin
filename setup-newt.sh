#!/bin/bash

set -euo pipefail

echo "==============================="
echo "  🐧 Installazione Newt v1.2+  "
echo "==============================="
echo ""

# === Raccogli input utente ===
read -rp "🔐 Inserisci ID dispositivo: " ID
while [[ -z "$ID" ]]; do
    echo "❌ L'ID non può essere vuoto."
    read -rp "🔐 Inserisci ID dispositivo: " ID
done

read -rp "🔐 Inserisci Secret: " SECRET
while [[ -z "$SECRET" ]]; do
    echo "❌ Il Secret non può essere vuoto."
    read -rp "🔐 Inserisci Secret: " SECRET
done

read -rp "🌐 Inserisci Endpoint (es: https://test.cloud): " ENDPOINT
while [[ -z "$ENDPOINT" || ! "$ENDPOINT" =~ ^https:// ]]; do
    echo "❌ Endpoint non valido. Deve iniziare con https://"
    read -rp "🌐 Inserisci Endpoint (es: https://test.cloud): " ENDPOINT
done

echo ""
echo "[*] Verifica dei permessi sudo..."
sudo -v

# === Aggiorna o installa newt ===
GITHUB_REPO="fosrl/newt"
INSTALL_PATH="/usr/local/bin/newt"
ARCH="linux_amd64"

echo "[*] Controllo ultima versione disponibile..."
LATEST_VERSION=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest" | grep -oP '"tag_name": "\K[^"]+')

if [[ -z "$LATEST_VERSION" ]]; then
    echo "❌ Errore: impossibile ottenere la versione da GitHub."
    exit 1
fi
echo "[+] Ultima versione: $LATEST_VERSION"

if [[ -x "$INSTALL_PATH" ]]; then
    LOCAL_VERSION=$("$INSTALL_PATH" --version 2>/dev/null | grep -oP 'v\d+\.\d+\.\d+')
else
    LOCAL_VERSION="none"
fi
echo "[+] Versione installata: $LOCAL_VERSION"

if [[ "$LOCAL_VERSION" != "$LATEST_VERSION" ]]; then
    echo "[*] Scarico e installo Newt $LATEST_VERSION..."
    TMP_FILE="/tmp/newt_update_$$"
    DOWNLOAD_URL="https://github.com/${GITHUB_REPO}/releases/download/${LATEST_VERSION}/newt_${ARCH}"
    curl -L -o "$TMP_FILE" "$DOWNLOAD_URL"
    sudo mv "$TMP_FILE" "$INSTALL_PATH"
    sudo chmod +x "$INSTALL_PATH"
else
    echo "✅ Newt è già aggiornato."
fi

# === Scrive configurazione ===
echo "[*] Scrivo configurazione in /etc/newt.env..."
sudo tee /etc/newt.env > /dev/null <<EOF
ID=$ID
SECRET=$SECRET
ENDPOINT=$ENDPOINT
EOF

# === Crea runner ===
echo "[*] Creo script runner..."
sudo tee /usr/local/bin/newt-runner.sh > /dev/null <<'EOF'
#!/bin/bash
source /etc/newt.env
exec /usr/local/bin/newt --id "$ID" --secret "$SECRET" --endpoint "$ENDPOINT" --accept-clients --native
EOF
sudo chmod +x /usr/local/bin/newt-runner.sh

# === Crea servizio ===
echo "[*] Creo servizio systemd..."
sudo tee /etc/systemd/system/newt.service > /dev/null <<EOF
[Unit]
Description=Pangolin Newt Connection Service
After=network.target

[Service]
ExecStart=/usr/local/bin/newt-runner.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# === Crea check script ===
echo "[*] Creo check script..."
sudo tee /usr/local/bin/check-newt.sh > /dev/null <<'EOF'
#!/bin/bash
if ! pgrep -f '/usr/local/bin/newt'; then
  systemctl restart newt.service
fi
EOF
sudo chmod +x /usr/local/bin/check-newt.sh

# === Crea check service ===
sudo tee /etc/systemd/system/check-newt.service > /dev/null <<EOF
[Unit]
Description=Check if Newt is running

[Service]
Type=oneshot
ExecStart=/usr/local/bin/check-newt.sh
EOF

# === Crea timer ===
sudo tee /etc/systemd/system/check-newt.timer > /dev/null <<EOF
[Unit]
Description=Timer to check newt every 5 minutes

[Timer]
OnBootSec=5min
OnUnitActiveSec=5min
Unit=check-newt.service

[Install]
WantedBy=timers.target
EOF

# === Abilita servizi ===
echo "[*] Attivo servizi..."
sudo systemctl daemon-reload
sudo systemctl enable --now newt.service
sudo systemctl enable --now check-newt.timer

echo ""
echo "✅ Installazione completata. Newt è attivo e verrà monitorato ogni 5 minuti."
