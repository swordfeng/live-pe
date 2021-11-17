#!/bin/bash
[ ! -e "$project" ] && echo '$project is not defined!' && exit 1

cd "$project/boot/grub"

rm -rf generated
mkdir -p generated/EFI/grub

# # EFI Grub
# grub-mkstandalone \
#    --format=x86_64-efi \
#    --output=generated/EFI/grub/grub.efi \
#    --locales="" \
#    --fonts="" \
#    --themes="" \
#    "boot/grub/grub.cfg=grub-efi.cfg"

# EFI Debian Only
m4 -DSEARCH_FILE=$(cat ../../search_file) grub-debian.cfg.m4 > generated/grub-debian.cfg
grub-mkstandalone \
   --format=x86_64-efi \
   --output=generated/EFI/grub/debian.efi \
   --install-modules="linux normal iso9660 all_video gfxterm search" \
   --modules="gfxterm" \
   --locales="" \
   --fonts="" \
   --themes="" \
   boot/grub/grub.cfg=generated/grub-debian.cfg

# MBR Grub
m4 -DSEARCH_FILE=$(cat ../../search_file) grub-mbr.cfg.m4 > generated/grub-mbr.cfg
grub-mkstandalone \
   --format=i386-pc \
   --output=generated/grub.img \
   --install-modules="linux16 linux normal iso9660 biosdisk memdisk search tar ls ntldr" \
   --modules="linux16 linux normal iso9660 biosdisk search ntldr" \
   --locales="" \
   --fonts="" \
   --themes="" \
   boot/grub/grub.cfg=generated/grub-mbr.cfg

# MBR Image
cat /usr/lib/grub/i386-pc/cdboot.img generated/grub.img > generated/boot.img
