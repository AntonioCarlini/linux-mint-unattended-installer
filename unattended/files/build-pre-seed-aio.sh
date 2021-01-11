#!/bin/sh
#
# This script builds a bootable ISO,from scratch, downloading everything that it needs.
#
# At the end of the building process, source area is a git repository that could be used
# for further development.
#
# Options:
#
# --source SOURCE
#    Specifies that SOURCE is root directory to be used when building the unattended ISO.
#    Defaults to using the current working directory as the source.
#
# --target TARGET
#    Specifies the filename of the generated unattended ISO

# NOTE: this is currently a work-in-progress
#

usage()
{
    echo "Usage: `basename "$0"` [--source SOURCE] [--target TARGET]"
    echo " SOURCE: the directory that contains the files that should be built into an ISO (defaults to the current directory)"
    echo " TARGET: the filename of the ISO to create (defaults to /tmp/mint-aio.iso)"
}

source="/tmp/mint"
target="/tmp/mint-aio.iso"
unrecognised_option=0
original_command_line="$@"

while [ $# -gt 0 ]
do
    echo "args: [$@]"
    case "$1" in
	-s|--source)
	    source="$2"
	    shift; shift # remove arg and value
	    ;;
	-t|--target)
	    target="$2"
	    shift; shift # remove arg and value
	    ;;
	*) # unknown option
	    echo "Unrecognised option: [$1]"
	    shift # remove unrecognised option
	    unrecognised_option=1
	    ;;
    esac
done

if [ "${unrecognised_option}" != "0" ]; then
    echo "At least one unrecognised option was seen: ${original_command_line}"
    usage
    exit
fi

mkisofs -D -r -V "AIO_MINT" -cache-inodes -J -l \
	-b isolinux/isolinux.bin \
	-c isolinux/boot.cat \
	-no-emul-boot -boot-load-size 4 -boot-info-table \
	-o "${target}" \
	"${source}"
#
#
# Notes for further development:
# future options:
# --iso-download
# --iso-mount
# --scratch
# --aio-iso
# --keep-iso
# --keep-scratch
# --cleanup

