# 🛠️ Dotfiles – Cross-Distro & macOS Config

This repository contains my personal configuration files (dotfiles) and preferences for quickly bootstrapping development or admin environments on:

* Oracle Linux
* Debian / Ubuntu
* Fedora Workstation / Server
* AlmaLinux / Rocky Linux
* **macOS** (Sonoma/Sequoia and newer)

## 📌 Features

* Unified `.bashrc`, `.vimrc`, `.gitconfig`, `.tigrc`, and more  
* Personal aliases and shell settings via `.laspavelrc`  
* Backup & restore automation with a single `bootstrap.sh` script  
* Compatible with both workstation, server, and macOS developer use cases  
* Extra: export of installed **pip3 packages** and macOS **Brewfile**  

## ⚙️ Requirements

* `git`, `rsync`, and basic Linux/macOS command-line tools  
* Optional: Homebrew on macOS (`https://brew.sh`)  
* Python with `pip3` (for exporting pip packages)  

## 🚀 Usage

### 🔄 Backup Dotfiles

You can back up your current configs:

```bash
./bootstrap.sh --backup
```

This will:
* copy dotfiles and console configs into the repository
* sync your `~/.local/scripts` into `./local/scripts`
* export Python packages into `pip3_packages.txt`
* on macOS: generate a `Brewfile` with all installed brew packages

You can enable file deletion during sync with `--delete` (or `RSYNC_DELETE=1`):

```bash
./bootstrap.sh --backup --delete
```

Schedule it as a cron job (Linux/macOS) to run twice a day:

```cron
0 2,14 * * * cd $HOME/_/dotfiles && ./bootstrap.sh --backup >> $HOME/dotfiles-backup.log 2>&1
```

### 📦 Restore Configuration

To restore and apply dotfiles into your `$HOME`:

```bash
./bootstrap.sh --restore
```

This will:
* copy all dotfiles from the repo into your home directory
* sync `./local/scripts` back into `~/.local/scripts`
* (optional) with `--delete` remove extra files in the destination during sync

By default, running without arguments is equivalent to `--restore`.

---

### 💡 Restoring Packages

* **Python (pip3):**
  ```bash
  python3 -m venv .venv && source .venv/bin/activate
  pip3 install -r pip3_packages.txt
  ```

* **macOS Homebrew:**
  ```bash
  brew tap Homebrew/bundle   # if not already tapped
  brew bundle --file ./Brewfile
  ```

---

## 📁 Included Configs

```plaintext
dotfiles/
├── .bashrc          # Shell customization
├── .vimrc           # Vim editor preferences
├── .gitconfig       # Git aliases and behavior
├── .tigrc           # tig viewer config
├── .toprc           # top process monitor UI
├── .psqlrc          # PostgreSQL CLI enhancements
├── .wgetrc          # Wget defaults
├── .nanorc          # Nano editor config
├── .lesshst         # less pager settings
├── .config/         # Console app configs (htop, mc, k9s, etc.)
├── local/scripts/   # Personal helper scripts
├── pip3_packages.txt# Exported pip3 package list
├── Brewfile         # Homebrew bundle file (macOS only)
├── bootstrap.sh     # Main install/backup script
```

## 🧪 Supported Systems

* Fedora Workstation & Server  
* Ubuntu (22.04+), Debian 11/12  
* AlmaLinux / Rocky Linux / Oracle Linux (8 & 9)  
* **macOS (Sonoma/Sequoia and newer)**  

## 📄 License

MIT License.

## 🤝 Contributions

Suggestions and improvements are welcome! Feel free to open an issue or submit a pull request.

## 📬 Contact

Author: [laspavel](https://github.com/laspavel)

---
