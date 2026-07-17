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

        if [ ! -e "~/.tmux.conf" ]; then
cat > ~/.tmux.conf <<EOF
set -g mouse on
unbind -n MouseDown3Pane
set -g default-command fish
EOF
tmux source ~/.tmux.conf
        fi
else
        if [ ! -e "~/.tmux.conf" ]; then
cat > ~/.tmux.conf <<EOF
set -g mouse on
unbind -n MouseDown3Pane
set -g default-command fish
EOF
tmux source ~/.tmux.conf
        fi
fi

if [ "$(tmux ls|grep '^default.*')" ]; then
        tmux a -t default
else
        tmux new -s default
fi
