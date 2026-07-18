#!/usr/bin/env bash
find /usr/lib/|grep -F /getty@|xargs -i sed -i 's,^ExecStart.*,ExecStart=-/sbin/agetty --noclear %I $TERM --autologin root,g' {}
systemctl daemon-reload
systemctl disable getty@tty1.service
systemctl enable getty@tty1.service