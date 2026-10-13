#!/usr/bin/env bash

qemu-img convert -f qcow2 -O raw $1 $2