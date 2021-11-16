#!/bin/bash
[ ! -e "$project" ] && echo '$project is not defined!' && exit 1

cd "$project/ucode"
rm -rf intel_ucode.tar.gz Intel-Linux-Processor-Microcode-* linux-firmware-*