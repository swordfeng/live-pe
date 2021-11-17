#!/bin/bash

[ ! -e "$project" ] && echo '$project is not defined!' && exit

cd "$project"

debian/gen.sh
ucode/gen.sh
boot/gen.sh

FILE="LIVE_PE_$(date -u +%Y%m%d_%H%M%S).iso"
cd image
sudo xorriso \
   -as mkisofs \
   -iso-level 3 \
   -output "../${FILE}" \
   -volid "$(cat ../hostname)" \
   -eltorito-boot boot/boot.img -no-emul-boot -boot-load-size 4 -boot-info-table \
   --eltorito-catalog boot/boot.cat \
   --grub2-boot-info --grub2-mbr /usr/lib/grub/i386-pc/boot_hybrid.img \
   -eltorito-alt-boot -e boot/efiboot.img -no-emul-boot \
   -append_partition 2 0xef ../boot/generated/efiboot.img \
   -graft-points \
      "." \
      /boot/boot.img=../boot/generated/boot.img \
      /boot/efiboot.img=../boot/generated/efiboot.img
      /boot/grub.cfg=../boot/grub/grub-usb.cf
ln -sf "${FILE}" ../LIVE_PE.iso
