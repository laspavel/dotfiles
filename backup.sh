#!/bin/bash

STARTDIR="$(pwd)"

PASS=`cat .pass`
DATE=`date '+%Y-%m-%d %H:%M:%S'`

mkdir -p $STARTDIR/src

#### dconf load /org/gnome/shell/extensions/dash-to-panel/ < dash_to_panel_settings
dconf dump /org/gnome/shell/extensions/dash-to-panel/ > $STARTDIR/src/dash_to_panel_settings
dconf dump /org/gnome/terminal/ > $STARTDIR/src/gnome_terminal_settings
pip3 freeze > $STARTDIR/src/pip3_packages.txt
dconf dump / > $STARTDIR/src/dump_gnome_settings

mkdir -p $STARTDIR/src/.config/mc
cp -rf ~/.config/mc/ini $STARTDIR/src/.config/mc/ini
cp -rf ~/.config/mc/panels.ini $STARTDIR/src/.config/mc/panels.ini
mkdir -p $STARTDIR/src/.config/htop
cp -rf ~/.config/htop/htoprc $STARTDIR/src/.config/htop/htoprc
cp -rf ~/.vimrc $STARTDIR/src
cp -rf ~/.toprc $STARTDIR/src
cp -rf ~/.tigrc $STARTDIR/src
cp -rf ~/.wgetrc $STARTDIR/src
cp -rf ~/.psqlrc $STARTDIR/src
cp -rf ~/.tmux $STARTDIR/src
cp -rf ~/.python_history $STARTDIR/src
cp -rf ~/.nanorc  $STARTDIR/src
cp -rf ~/.lesshst $STARTDIR/src
cp -rf ~/.gitconfig $STARTDIR/src
cp -rf ~/.gitignore $STARTDIR/src
cp -rf ~/.bashrc $STARTDIR/src
cp -rf ~/.laspavelrc $STARTDIR/src
cp -rf ~/.bash_profile $STARTDIR/src
cp -rf ~/.bash_logout $STARTDIR/src
cp -rf ~/.bash_history $STARTDIR/src
cp -rf ~/.ssh $STARTDIR/src

cd $STARTDIR/src
zip -P$PASS -9 -q -r -m ./.ssh.zip ./.ssh
zip -P$PASS -9 -q -r -m ./.tmux.zip ./.tmux
zip -P$PASS -9 -q -r -m ./.bash_history.zip ./.bash_history
zip -P$PASS -9 -q -r -m ./dump_gnome_settings.zip ./dump_gnome_settings

cd $STARTDIR

git add .
git commit -a -m "new backup $DATE"
git push origin master
git push --tags



