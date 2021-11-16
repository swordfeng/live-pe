#!/bin/bash
[ ! -e "$project" ] && echo '$project is not defined!' && exit 1

cd "$project/boot"
grub/gen.sh || exit 1
refind/gen.sh || exit 1

mkdir -p generated/esp/EFI/grub
cp grub/generated/EFI/grub/debian.efi generated/esp/EFI/grub/debian.efi || exit 1

mkdir -p generated/esp/EFI/boot
cp refind/generated/EFI/refind/refind.efi generated/esp/EFI/boot/bootx64.efi || exit 1
cp refind/generated/EFI/refind/refind.conf generated/esp/EFI/boot/refind.conf || exit 1

# mkdir -p generated/esp/EFI/microsoft/boot
# cp ../image/efi/microsoft/boot/bootmgr.efi generated/esp/EFI/microsoft/boot/bootmgr.efi || exit 1

# mkdir -p generated/esp/grubfm
# cp ../image/grubfm/grubfmx64.efi generated/esp/grubfm/grubfmx64.efi || exit 1

# mkdir -p generated/esp/EFI/shell
# cp ../image/efi/shell/shell.efi generated/esp/EFI/shell/shell.efi || exit 1

export LC_CTYPE=C

# first pass to get size
rm generated/efiboot.img
truncate -s 16M generated/efiboot.img
mkfs.vfat generated/efiboot.img && \
    mcopy -i generated/efiboot.img -s ./generated/esp/* :: || exit 1
img_size=$(du -k generated/efiboot.img | cut -f1)

# second pass to create image
mkdir -p "$project/image/boot"
rm "$project/image/boot/efiboot.img"
fallocate -l ${img_size}K "$project/image/boot/efiboot.img"
mkfs.vfat -v "$project/image/boot/efiboot.img" && \
    mcopy -i "$project/image/boot/efiboot.img" -s ./generated/esp/* :: || exit 1

cp grub/generated/boot.img "$project/image/boot/boot.img" || exit 1

touch "$project/image/boot/$(cat "$project/search_file")"