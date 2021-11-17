insmod all_video

set default="0"
set timeout=30
set gfxpayload=keep

menuentry "Debian Live" {
    search --set=root --no-floppy --file /boot/SEARCH_FILE
    linux /live/vmlinuz boot=live components quiet splash ---
    initrd /boot/intel-ucode.img /boot/amd-ucode.img /live/initrd.img
}

menuentry "Windows PE" {
    search --set=root --no-floppy --file /boot/SEARCH_FILE
    ntldr /boot/bootmgr
}
