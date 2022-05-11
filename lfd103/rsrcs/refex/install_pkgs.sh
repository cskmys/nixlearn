#!/bin/bash

sudo apt install "alsa-utils"
echo "alias beep=\"speaker-test -f 500 -t sine -l 1\"" >> "${HOME}/.bash_aliases"
sudo apt install "build-essential" "libelf-dev" "vim" "git" "cscope" "libncurses-dev" "libssl-dev" "bison" "flex" "psmisc" "man-db" "locate" "bc" "mokutil"
sudo updatedb
beep
