insmod all_video
search --set=root --no-floppy --file /boot/SEARCH_FILE

set default="0"
set timeout=0
set gfxpayload=keep

menuentry "Debian Live" {
    linux /live/vmlinuz boot=live components quiet splash ---
    initrd /boot/intel-ucode.img /boot/amd-ucode.img /live/initrd.img
}
