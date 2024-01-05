#!/bin/bash

# To cron: 00 14 * * * laspavel cd /home/laspavel/_/dotfiles/ && ./bootstrap.sh --backup

function RestoreDotFiles() {
    if which git >/dev/null 2>&1; then
        # save old global git config
        OLDMASK=$(umask)
        umask 0077
        git config --global -l | LANG=C sort > .oldgit$$.tmp
        umask $OLDMASK
    fi

    OS='rpm_compat' # default to RPM compatible
    if [ -d /etc/apt/sources.list.d/ ]; then
        OS='deb_compat'
    fi

    if which rsync >/dev/null 2>&1; then
        echo "Rsync found - OK ! "
    else
        if [ "$OS" == "deb_compat" ]; then
            apt-get update
            apt-get -y install rsync
        fi
        if [ "$OS" == "rpm_compat" ]; then
            yum -y install rsync
        fi
    fi
    
    if which rsync >/dev/null 2>&1; then
        rsync --exclude ".git/" \
            --exclude "bootstrap.sh" \
            --exclude "README.md" \
            --exclude "LICENSE" \
            -avh --no-perms . ~;
    else
        echo "Rsync not installed... Copy aborted !"
    fi
}

function BackupDotFiles () {
    STARTDIR="$(pwd)"
    PASS=`cat .pass`
    DATE=`date '+%Y-%m-%d %H:%M:%S'`
    mkdir -p $STARTDIR/DOD1

    OS='rpm_compat' # default to RPM compatible
    if [ -d /etc/apt/sources.list.d/ ]; then
        OS='deb_compat'
    fi

    if which zip >/dev/null 2>&1; then
        echo "ZIP found - OK ! "
    else
        if [ "$OS" == "deb_compat" ]; then
            apt-get update
            apt-get -y install zip
        fi
        if [ "$OS" == "rpm_compat" ]; then
            yum -y install zip
        fi
    fi

    #### dconf load /org/gnome/shell/extensions/dash-to-panel/ < dash_to_panel_settings
    if which dconf >/dev/null 2>&1; then
        dconf dump /org/gnome/shell/extensions/dash-to-panel/ > $STARTDIR/DOD1/dash_to_panel_settings
        dconf dump /org/gnome/terminal/ > $STARTDIR/DOD1/gnome_terminal_settings
        dconf dump / > $STARTDIR/DOD1/dump_gnome_settings
    fi
    if which pip3 >/dev/null 2>&1; then
        pip3 freeze > $STARTDIR/DOD1/pip3_packages.txt
    fi
    
    mkdir -p $STARTDIR/.config/mc
    cp -rf ~/.config/mc/ini $STARTDIR/.config/mc/ini
    cp -rf ~/.config/mc/panels.ini $STARTDIR/.config/mc/panels.ini
    mkdir -p $STARTDIR/.config/doublecmd
    cp -rf ~/.config/doublecmd/colors.json $STARTDIR/.config/doublecmd/colors.json
    cp -rf ~/.config/doublecmd/doublecmd.xml $STARTDIR/.config/doublecmd/doublecmd.xml
    mkdir -p $STARTDIR/.config/htop
    cp -rf ~/.config/htop/htoprc $STARTDIR/.config/htop/htoprc
    cp -rf ~/.vimrc $STARTDIR
    cp -rf ~/.toprc $STARTDIR
    cp -rf ~/.tigrc $STARTDIR
    cp -rf ~/.wgetrc $STARTDIR
    cp -rf ~/.psqlrc $STARTDIR
    cp -rf ~/.tmux $STARTDIR/DOD1
    cp -rf ~/.python_history $STARTDIR/DOD1
    cp -rf ~/.nanorc  $STARTDIR
    cp -rf ~/.lesshst $STARTDIR
    cp -rf ~/.gitconfig $STARTDIR
    cp -rf ~/.gitignore $STARTDIR
    cp -rf ~/.laspavelrc $STARTDIR
    cp -rf ~/.bash_profile $STARTDIR
    cp -rf ~/.bash_logout $STARTDIR
    cp -rf ~/.bash_history $STARTDIR/DOD1
    cp -rf ~/.ssh $STARTDIR/DOD1

    cd $STARTDIR/DOD1
    zip -P$PASS -9 -q -r -m ./.ssh.zip ./.ssh
    zip -P$PASS -9 -q -r -m ./.tmux.zip ./.tmux
    zip -P$PASS -9 -q -r -m ./.bash_history.zip ./.bash_history
    zip -P$PASS -9 -q -r -m ./.python_history.zip ./.python_history
    zip -P$PASS -9 -q -r -m ./dump_gnome_settings.zip ./dump_gnome_settings

    cd $STARTDIR
    git add .
    git commit -a -m "new backup $DATE"
#    git push origin --all
#    git push --tags
}

if [ "$1" == "--backup" -o "$1" == "-b" ]; then
    BackupDotFiles;
else
    RestoreDotFiles;
fi;
unset BackupDotFiles;
unset RestoreDotFiles;




