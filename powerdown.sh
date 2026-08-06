#!/usr/bin/env bash

if [ -e "/proc/sys/kernel/sysrq" ]; then
    echo 1 | tee /proc/sys/kernel/sysrq
else
    echo "not support"
    exit 0
fi

if [ -e "/proc/sysrq-trigger" ]; then
    echo r | tee /proc/sysrq-trigger
    sleep 1
    echo e | tee /proc/sysrq-trigger
    sleep 2
    echo i | tee /proc/sysrq-trigger
    sleep 2
    echo s | tee /proc/sysrq-trigger
    sleep 2
    echo u | tee /proc/sysrq-trigger
    sleep 2
    echo o | tee /proc/sysrq-trigger
else
    echo "not exist /proc/sysrq-trigger"
fi