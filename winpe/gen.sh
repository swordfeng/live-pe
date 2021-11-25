#!/bin/bash
[ ! -e "$project" ] && echo '$project is not defined!' && exit 1

cd "$project/winpe"

mkdir -p iso
sudo mount -o ro Win10XPE/Win10XPE_x64.ISO iso

mkdir -p "$project/image/boot"
mkdir -p "$project/image/efi/microsoft/boot"
cp --no-preserve=mode iso/BOOTMGR "$project/image/boot/bootmgr"
cp --no-preserve=mode iso/efi/boot/bootx64.efi "$project/image/efi/microsoft/boot/bootx64.efi"
cp --no-preserve=mode iso/boot/boot.sdi "$project/image/boot/boot.sdi"

mkdir -p "$project/image/live"
cp --no-preserve=mode iso/sources/boot.wim "$project/image/live/boot.wim"

sudo umount iso
