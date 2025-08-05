# 🐧 Newt Host Setup - Pangolin Auto Connect

Script Bash per installare, configurare e mantenere in esecuzione persistente il client [`newt`](https://github.com/fosrl/newt) su dispositivi Linux, facilitando la connessione alla rete **Pangolin** in modalità headless.

---

## 📦 Contenuto

| File                | Descrizione                                                                 |
|---------------------|-----------------------------------------------------------------------------|
| [`setup-newt.sh`](./setup-newt.sh)   | Script interattivo per installare `newt`, configurare il servizio systemd e garantire la persistenza con monitoraggio |
| [`remove-newt.sh`](./remove-newt.sh) | Script per rimuovere completamente `newt` e tutte le configurazioni correlate |
| [`README.md`](./README.md)           | Questa guida ✨ |

---

## ⚙️ Requisiti

- Linux (testato su Ubuntu/Debian)
- Permessi `sudo`

---

## 🚀 Installazione

```bash
git clone https://github.com/ddutcho/Newt.git
cd Pangolin
chmod +x setup-newt.sh
./setup-newt.sh
```

---

## 🧠 Lo script chiederà:

- 🔐 **ID del dispositivo**
- 🔐 **Secret**
- 🌐 **Endpoint** (es: `https://test.ex`)

E si occuperà di:

- 📥 Scaricare l'ultima versione disponibile di `newt` da GitHub
- ⚙️ Installarlo e configurarlo con i flag: `--accept-clients --native`
- 🛠 Creare un servizio `systemd` che lo avvia e lo mantiene attivo
- 🔄 Creare un controllo periodico ogni 5 minuti via `systemd timer`

---

## 🔄 Aggiornamento automatico

Lo script [`setup-newt.sh`](./setup-newt.sh) **verifica e aggiorna `newt`** se necessario ogni volta che viene eseguito.

---

## ❌ Disinstallazione

Per rimuovere tutto:

```bash
chmod +x remove-newt.sh
sudo ./remove-newt.sh
```

---

## 📋 Controlli utili

- ✅ **Stato del servizio**:
  ```bash
  systemctl status newt
  ```

- 📝 **Log in tempo reale**:
  ```bash
  journalctl -u newt -f
  ```

- 🔁 **Forzare un riavvio**:
  ```bash
  sudo systemctl restart newt
  ```

---
