#!/bin/bash
[ ! -e "$project" ] && echo '$project is not defined!' && exit 1

cd "$project/debian"
rm -rf keyring.gpg*
sudo rm -rf liveroot
