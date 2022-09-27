# dotfiles

Dotfiles for my start.

**Requirements:**
* Git
* Zip
* if required backup all gnome configs with password - add password to .pass

**Usage:**
```
backup.sh
```
or add /etc/cron.d/backup_dotfiles:
```
00 14 * * * laspavel cd /home/laspavel/_/dotfiles/ && ./backup.sh
```
