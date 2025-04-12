# 🛠️ Dotfiles – Cross-Distro Config for Linux Workstations and Servers

This repository contains my personal Linux configuration files (dotfiles) and preferences for quickly bootstrapping development or admin environments on:

* Oracle Linux
* Debian / Ubuntu
* Fedora Workstation / Server
* AlmaLinux / Rocky Linux

## 📌 Features

* Unified .bashrc, .vimrc, .gitconfig, .tigrc, and more
* Personal aliases and shell settings via .laspavelrc
* Preconfigured .config/ for GNOME tools and other desktop apps
* Backup & restore automation with a single bootstrap.sh script
* Compatible with both workstation and server use cases

## ⚙️ Requirements

* git, zip, and basic Linux command-line tools
* Optional: password for GNOME config backup saved in .pass file

## 🚀 Usage

### 🔄 Backup Existing Dotfiles
You can back up your current configs:

```bash
./bootstrap.sh --backup
```

Or schedule it as a daily cron task:

```cron
00 14 * * * laspavel cd /home/laspavel/_/dotfiles/ && ./bootstrap.sh --backup
```

This will archive your current dotfiles and GNOME settings (if applicable).

### 📦 Restore Configuration

To install and apply all dotfiles from this repository:

```bash
./bootstrap.sh
```

The script will symlink configs into your $HOME, replacing existing ones after backing them up.

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
├── .config/         # GNOME and other desktop app configs
├── bootstrap.sh     # Main install/backup script
```

## 🧪 Supported Systems

* Fedora Workstation & Server
* Ubuntu (22.04+), Debian 11/12
* AlmaLinux / Rocky Linux / Oracle Linux (8 & 9)

## 📄 License

MIT License.

## 🤝 Contributions

Suggestions and improvements are welcome! Feel free to open an issue or submit a pull request.

## 📬 Contact

Author: [laspavel](https://github.com/laspavel)

Feel free to reach out with questions or ideas.

---
