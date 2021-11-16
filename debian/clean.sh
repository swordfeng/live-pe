#!/bin/bash
[ ! -e "$project" ] && echo '$project is not defined!' && exit

cd "$project/debian"
rm -rf keyring.gpg*
sudo rm -rf liveroot
