#!/bin/sh

fetch_keyring() {
    version=$(curl https://deb.debian.org/debian/dists/stable/InRelease | perl -n -e'/^Version: ([0-9]+).*$/ && print $1')
    curl https://ftp-master.debian.org/keys/release-${version}.asc | gpg --no-default-keyring --keyring=$PWD/keyring.gpg --import
    curl https://ftp-master.debian.org/keys/archive-key-${version}.asc | gpg --no-default-keyring --keyring=$PWD/keyring.gpg --import
    curl https://ftp-master.debian.org/keys/archive-key-${version}-security.asc | gpg --no-default-keyring --keyring=$PWD/keyring.gpg --import
}

init() {
    mkdir -p liveroot
    debootstrap --keyring=$PWD/keyring.gpg --variant=minbase stable liveroot http://deb.debian.org/debian/
    cat hostname > liveroot/etc/hostname
}

# [ ! -e liveroot ] && fetch_keyring && sudo bash -c "$(declare -f init); init"
fetch_keyring
sudo bash -c "$(declare -f init); init"