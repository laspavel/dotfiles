sudo systemctl stop power-profiles-daemon.service
sudo systemctl disable power-profiles-daemon.service
sudo systemctl mask power-profiles-daemon.service

sudo dnf install tlp tlp-rdw
sudo systemctl enable tlp
sudo systemctl start tlp
sudo systemctl status tlp

sudo tlp-stat -s 

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.github.d4nj1.tlpui

---
https://knowledgebase.frame.work/en_us/optimizing-fedora-battery-life-r1baXZh