#!/bin/bash

# Применение настроек GNOME через gsettings и dconf
# Он должен запускаться внутри пользовательской сессии (с установленным DBUS_SESSION_BUS_ADDRESS и DISPLAY).

# Включить расширение dash-to-panel
gsettings set org.gnome.shell enabled-extensions "['dash-to-panel@jderose9.github.com']"

# Загрузка конфигурации терминала
#
# Для создания конфигурации: dconf dump /org/... > gnome_settings_....dump
#
dconf load -f /org/gnome/terminal/ < gnome_settings_terminal.dump
dconf load -f /org/gnome/Ptyxis/ < gnome_settings_Ptyxis.dump

# Загрузка конфигурации dash-to-panel
dconf load -f /org/gnome/shell/extensions/dash-to-panel/ < dash_to_panel_settings.dump

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

# Nautilus: иконки
gsettings set org.gnome.nautilus.icon-view default-zoom-level 'medium'

# GTK FileChooser
dconf write /org/gtk/settings/file-chooser/sort-directories-first true

# Nautilus: древовидный режим в списке
gsettings set org.gnome.nautilus.list-view use-tree-view true

# Внешний вид GNOME (Фон рабочего стола)
gsettings set org.gnome.desktop.background color-shading-type 'solid'
gsettings set org.gnome.desktop.background picture-options 'zoom'
gsettings set org.gnome.desktop.background picture-uri "file://$HOME/.local/share/backgrounds/b04.jpg"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$HOME/.local/share/backgrounds/b04.jpg"
gsettings set org.gnome.desktop.background primary-color '#000000000000'
gsettings set org.gnome.desktop.background secondary-color '#000000000000'

# Внешний вид GNOME (Цветовая схема интерфейса)
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface accent-color 'blue'

# Внешний вид GNOME (screensaver)
gsettings set org.gnome.desktop.screensaver color-shading-type 'solid'
gsettings set org.gnome.desktop.screensaver picture-options 'zoom'
gsettings set org.gnome.desktop.screensaver picture-uri "file://$HOME/.local/share/backgrounds/b04.jpg"
gsettings set org.gnome.desktop.screensaver primary-color '#000000000000'
gsettings set org.gnome.desktop.screensaver secondary-color '#000000000000'
