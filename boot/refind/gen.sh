#!/bin/bash
[ ! -e "$project" ] && echo '$project is not defined!' && exit 1

cd "$project/boot/refind"

rm -rf generated
mkdir -p generated/EFI/refind

cp /usr/share/refind/refind_x64.efi generated/EFI/refind/refind.efi
cp refind.conf generated/EFI/refind/refind.conf
