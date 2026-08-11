#!/usr/bin/env bash

qemu-img convert -f qcow2 -O vpc -o subformat=fixed $*