#!/bin/bash
[ ! -e "$project" ] && echo '$project is not defined!' && exit

cd "$project/ucode"
rm -rf intel_ucode.tar.gz Intel-Linux-Processor-Microcode-* linux-firmware-*