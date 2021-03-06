#!/bin/bash
[ ! -e "$project" ] && echo '$project is not defined!' && exit 1
[ ! -e "$project/image/boot/bootmgr" ] && echo 'Please run winpe/gen.sh first!' && exit 1

cd "$project/boot"
grub/gen.sh || exit 1
refind/gen.sh || exit 1

cd "$project/boot"
rm -rf generated
mkdir -p generated/esp/EFI/grub
cp grub/generated/EFI/grub/debian.efi generated/esp/EFI/grub/debian.efi || exit 1

mkdir -p generated/esp/EFI/boot
cp refind/generated/EFI/refind/refind.efi generated/esp/EFI/boot/bootx64.efi || exit 1
cp refind/generated/EFI/refind/refind.conf generated/esp/EFI/boot/refind.conf || exit 1

mkdir -p generated/esp/EFI/winpe
cp ../image/efi/microsoft/boot/bootx64.efi generated/esp/EFI/winpe/bootmgfw.efi || exit 1

# mkdir -p generated/esp/grubfm
# cp ../image/grubfm/grubfmx64.efi generated/esp/grubfm/grubfmx64.efi || exit 1

# mkdir -p generated/esp/EFI/shell
# cp ../image/efi/shell/shell.efi generated/esp/EFI/shell/shell.efi || exit 1

export LC_CTYPE=C

# first pass to get size
[ -e generated/efiboot.img ] && rm generated/efiboot.img
truncate -s 16M generated/efiboot.img
mkfs.vfat generated/efiboot.img && \
    mcopy -i generated/efiboot.img -s ./generated/esp/* :: || exit 1
img_size=$(du -k generated/efiboot.img | cut -f1)
rm generated/efiboot.img

# second pass to create image
mkdir -p "$project/image/boot"
rm "$project/image/boot/efiboot.img"
fallocate -l ${img_size}K "$project/image/boot/efiboot.img"
mkfs.vfat -v "$project/image/boot/efiboot.img" && \
    mcopy -i "$project/image/boot/efiboot.img" -s ./generated/esp/* :: || exit 1

cp grub/generated/boot.img "$project/image/boot/boot.img" || exit 1

mkdir -p "$project/image/boot/grub"
cp grub/grub-usb.cfg "$project/image/boot/grub/grub.cfg" || exit 1

cp bootmgr/generated/bcd "$project/image/boot/bcd" || exit 1
mkdir -p "$project/image/efi/microsoft/boot"
cp bootmgr/generated/bcd_efi "$project/image/efi/microsoft/boot/bcd" || exit 1

[ ! -e wimboot ] && curl -o wimboot -L https://github.com/ipxe/wimboot/releases/latest/download/wimboot
cp wimboot "$project/image/boot/wimboot"

touch "$project/image/boot/$(cat "$project/search_file")"