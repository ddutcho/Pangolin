#!/bin/bash

echo "[*] Richiesta password sudo..."
sudo -v

echo "[*] Fermo i servizi..."
sudo systemctl stop newt.service 2>/dev/null
sudo systemctl disable newt.service 2>/dev/null
sudo systemctl stop check-newt.timer 2>/dev/null
sudo systemctl disable check-newt.timer 2>/dev/null
sudo systemctl disable check-newt.service 2>/dev/null

echo "[*] Rimuovo file di sistema..."
sudo rm -f /usr/local/bin/newt
sudo rm -f /usr/local/bin/newt-runner.sh
sudo rm -f /usr/local/bin/check-newt.sh
sudo rm -f /etc/newt.env

echo "[*] Rimuovo unità systemd..."
sudo rm -f /etc/systemd/system/newt.service
sudo rm -f /etc/systemd/system/check-newt.service
sudo rm -f /etc/systemd/system/check-newt.timer

echo "[*] Ricarico configurazione systemd..."
sudo systemctl daemon-reload
sudo systemctl reset-failed

echo "✅ Tutti i componenti di Newt sono stati rimossi."
