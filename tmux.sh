#!/usr/bin/env bash
set -x
if ! command -v tmux > /dev/null 2>&1; then
        if command -v apt > /dev/null 2>&1; then
                apt install -y tmux fish
        elif command -v apk > /dev/null 2>&1; then
                apk add tmux fish
        elif command -v pacman > /dev/null 2>&1; then
                pacman --noconfirm -Sy fish tmux
        else
                exit 1
        fi
fi
if command -v tmux > /dev/null 2>&1; then
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