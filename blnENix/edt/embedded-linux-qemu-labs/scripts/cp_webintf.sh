#!/bin/bash

WEB_BASE_PATH="/home/csk/edt/nixlearn/blnENix/edt/embedded-linux-qemu-labs/tinysystem/data/www"

NFS_BASE_PATH="/home/csk/edt/nixlearn/blnENix/edt/embedded-linux-qemu-labs/tinysystem/nfsroot"
NFS_WEB="${NFS_BASE_PATH:?}/www"

mkdir -p "${NFS_WEB}"

mv "${WEB_BASE_PATH}" "${NFS_HOME}"
