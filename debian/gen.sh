#!/bin/sh
[ ! -e "$project" ] && echo '$project is not defined!' && exit 1

fetch_keyring() {
    version=$(curl https://deb.debian.org/debian/dists/stable/InRelease | perl -n -e'/^Version: ([0-9]+).*$/ && print $1')
    curl https://ftp-master.debian.org/keys/release-${version}.asc | gpg --no-default-keyring --keyring=$PWD/keyring.gpg --import
    curl https://ftp-master.debian.org/keys/archive-key-${version}.asc | gpg --no-default-keyring --keyring=$PWD/keyring.gpg --import
    curl https://ftp-master.debian.org/keys/archive-key-${version}-security.asc | gpg --no-default-keyring --keyring=$PWD/keyring.gpg --import
    true
}

init() {
    mkdir -p liveroot
    debootstrap --keyring=$PWD/keyring.gpg --variant=minbase stable liveroot http://deb.debian.org/debian/
    cat ../hostname > liveroot/etc/hostname
}

chroot_setup() {
    export PATH=/usr/sbin:/usr/bin:/sbin:/bin
    export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true

    # set apt sources
    apt update && apt install --no-install-recommends -y lsb-release ca-certificates || return 1
    CODENAME=$(lsb_release --codename --short)
    cat > /etc/apt/sources.list << HEREDOC
deb https://deb.debian.org/debian/ $CODENAME main contrib non-free
deb-src https://deb.debian.org/debian/ $CODENAME main contrib non-free

deb https://security.debian.org/debian-security $CODENAME-security main contrib non-free
deb-src https://security.debian.org/debian-security $CODENAME-security main contrib non-free

deb https://deb.debian.org/debian/ $CODENAME-updates main contrib non-free
deb-src https://deb.debian.org/debian/ $CODENAME-updates main contrib non-free
HEREDOC

    # install packages
    apt update && apt install --no-install-recommends -y \
        linux-image-amd64 \
        live-boot \
        systemd-sysv \
        sudo

    apt install --no-install-recommends -y \
        locales \
        xfce4 \
        xserver-xorg \
        nodm \
        dbus-x11 \
        firmware-amd-graphics \
        firmware-misc-nonfree \
        xinput

    # locale
    sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    echo LANG=en_US.UTF-8 > /etc/default/locale
    locale-gen

    # lightdm
    # sed -i 's/#greeter-session=.*/greeter-session=lightdm-gtk-greeter/' /etc/lightdm/lightdm.conf
    # sed -i 's/#user-session=.*/user-session=xfce/' /etc/lightdm/lightdm.conf

    # use empty root password
    passwd -d root
    # useradd -m -G sudo live
    # passwd -d live
    # echo "live ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/live
    # chmod 0440 /etc/sudoers.d/live
}

cleanup() {
    chroot liveroot apt clean
    rm -rf liveroot/tmp/* liveroot/var/log/* liveroot/root/{.bash_history,.vim,.viminfo,.cache}
}

gen_squashfs() {
    rm "$project/image/live/filesystem.squashfs"
    if [ x$env = xrelease ]; then
        mksquashfs liveroot "$project/image/live/filesystem.squashfs" -comp xz -Xbcj x86 -Xdict-size 100%
    else
        mksquashfs liveroot "$project/image/live/filesystem.squashfs" -comp zstd -Xcompression-level 3
    fi
}

gen_kernel() {
    rm "$project/image/live/"{initrd.img,vmlinuz}
    cp liveroot/boot/initrd.img-* "$project/image/live/initrd.img"
    cp liveroot/boot/vmlinuz-* "$project/image/live/vmlinuz"
}


cd "$project/debian"

[ ! -e keyring.gpg ] && fetch_keyring

[ ! -e liveroot ] && sudo -E bash -c "$(declare -f init); init" && \
    sudo -E chroot liveroot/ /bin/bash -c "$(declare -f chroot_setup); chroot_setup"

mkdir -p "$project/image/live"
sudo -E bash -c "$(declare -f cleanup); cleanup"
sudo -E bash -c "$(declare -f gen_squashfs); gen_squashfs"
sudo -E bash -c "$(declare -f gen_kernel); gen_kernel"

printf $(sudo du -sx --block-size=1 liveroot | cut -f1) > "$project/image/live/filesystem.size"
