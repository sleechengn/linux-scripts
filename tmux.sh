#!/usr/bin/env bash

if [ ! "$(which tmux)" ]; then

        if [ "$(which apt)" ]; then
                apt install -y tmux fish
        else
                if [ "$(which apk)" ]; then
                        apk add tmux fish
                else
                        if [ "$(which pacman)" ]; then
                                pacman --noconfirm -Sy fish tmux
                        else
                                exit 1
                        fi
                fi
        fi
fi

if [ "$(which tmux)" ]; then

        if [ ! -e "~/.tmux.conf" ]; then
cat > ~/.tmux.conf <<EOF
set -g mouse on
unbind -n MouseDown3Pane
set -g default-command fish
EOF
        tmux source ~/.tmux.conf
        fi

        if [ "$(tmux ls|grep '^default.*')" ]; then
                tmux a -t default
        else
                tmux new -s default
        fi

        if [ $(id -u $(whoami)) -eq 0 ] && [ ! -e "/usr/bin/t" ] ; then
                cp $0 /usr/bin/t
                chmod 755 /usr/bin/t
        fi

fi


