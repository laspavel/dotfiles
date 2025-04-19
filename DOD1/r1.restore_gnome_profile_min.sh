#!/bin/bash

# Применение настроек GNOME через gsettings и dconf
# Он должен запускаться внутри пользовательской сессии (с установленным DBUS_SESSION_BUS_ADDRESS и DISPLAY).

# Загрузка конфигурации терминала
#
# Create dump: dconf dump / > dump_gnome
#
dconf load -f /org/gnome/terminal/ < gnome_settings_terminal
dconf load -f /org/gnome/Ptyxis/ < gnome_settings_Ptyxis

# Загрузка конфигурации dash-to-panel
dconf load -f /org/gnome/shell/extensions/dash-to-panel/ < dash_to_panel_settings

# Отключить баннеры уведомлений
gsettings set org.gnome.desktop.notifications show-banners false

# Отключить уведомления на экране блокировки
gsettings set org.gnome.desktop.notifications show-in-lock-screen false

# Отключить отправку технических проблем
gsettings set org.gnome.desktop.privacy report-technical-problems false

# Обновить расположение кнопок окон
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'

# Отключить автоматическое обновление программного обеспечения
gsettings set org.gnome.software allow-updates false
gsettings set org.gnome.software download-updates false
gsettings set org.gnome.software download-updates-notify false

# Настройки клавиатуры
gsettings set org.gnome.settings-daemon.peripherals.keyboard remember-numlock-state true

# Настройки Gedit кодировок
gsettings set org.gnome.gedit.preferences.encodings candidate-encodings "['UTF-8', 'WINDOWS-1251', 'KOI8-R', 'CURRENT', 'ISO-8859-15', 'UTF-16']"

# Настройки мыши
gsettings set org.gnome.desktop.peripherals.mouse accel-profile 'adaptive'

# Звук
gsettings set org.gnome.desktop.sound allow-volume-above-100-percent true

# Календарь
gsettings set org.gnome.desktop.calendar show-weekdate true

# Окна (правый клик для resize)
gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true

# Окна (расположение кнопок)
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'

# GNOME Shell
gsettings set org.gnome.shell.overrides workspaces-only-on-primary false

# Nautilus: иконки
gsettings set org.gnome.nautilus.icon-view default-zoom-level 'standard'

# Nautilus: текстовые файлы
gsettings set org.gnome.nautilus.preferences executable-text-activation 'ask'

# GTK FileChooser (внимание: нестандартный формат секции)
gsettings set org.gtk.Settings.FileChooser sort-directories-first true

# Nautilus: древовидный режим в списке
gsettings set org.gnome.nautilus.list-view use-tree-view true

# Включить расширение dash-to-panel
gsettings set org.gnome.shell enabled-extensions "['dash-to-panel@jderose9.github.com']"
