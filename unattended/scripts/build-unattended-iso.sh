#!/bin/sh
#
# This script builds a bootable ISO. It expects to be invoked the directory that
# contains everything that should be included in the ISO.
#
# NOTE: this is currently a work-in-progress

mkisofs -D -r -V "AIO_MINT" -cache-inodes -J -l \
	-b isolinux/isolinux.bin \
	-c isolinux/boot.cat \
	-no-emul-boot -boot-load-size 4 -boot-info-table \
	-o /tmp/linux-mint-20.1-unattended-install.iso \
	/tmp/mint
