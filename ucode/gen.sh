#!/bin/bash
[ ! -e "$project" ] && echo '$project is not defined!' && exit 1

intel_ucode_ver=20210608
amd_ucode_ver=20211027

fetch_intel() (
    curl -o intel_ucode.tar.gz -L https://github.com/intel/Intel-Linux-Processor-Microcode-Data-Files/archive/microcode-${intel_ucode_ver}.tar.gz
    rm -rf Intel-Linux-Processor-Microcode-Data-Files-microcode-*
    tar xf intel_ucode.tar.gz

    cd Intel-Linux-Processor-Microcode-Data-Files-microcode-${intel_ucode_ver}
    rm -f intel-ucode{,-with-caveats}/list
    iucode_tool --write-earlyfw=../intel-ucode.img intel-ucode{,-with-caveats}/
)

fetch_amd() (
    echo $PWD
    curl -o linux-firmware.tar.gz -L https://cdn.kernel.org/pub/linux/kernel/firmware/linux-firmware-${amd_ucode_ver}.tar.gz
    rm -rf linux-firmware-*
    tar xf linux-firmware.tar.gz
    cd linux-firmware-${amd_ucode_ver}
    mkdir -p kernel/x86/microcode
    cat amd-ucode/microcode_amd*.bin > kernel/x86/microcode/AuthenticAMD.bin
    echo kernel/x86/microcode/AuthenticAMD.bin | bsdtar --uid 0 --gid 0 -cnf - -T - | bsdtar --null -cf - --format=newc @- > ../amd-ucode.img
)

mkdir -p "$project/image/boot"
cd "$project/ucode"

[ ! -e intel-ucode.img ] && fetch_intel
cp intel-ucode.img "$project/image/boot/intel-ucode.img"

[ ! -e amd-ucode.img ] && fetch_amd
cp amd-ucode.img "$project/image/boot/amd-ucode.img"