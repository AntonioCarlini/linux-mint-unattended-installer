#!/bin/bash
#
# This script builds a bootable ISO. 
# Options:
#
# --source SOURCE
#    Specifies that SOURCE is root directory to be used when building the unattended ISO.
#    Defaults to using the current working directory as the source.
#    If the CWD is not the root of the copied LM ISO file then mkisofs will probably fail.
#
# --target TARGET
#    Specifies the filename (and path) of the generated unattended ISO.
#
# --help
#    Displays usage information.

usage()
{
    echo "Usage: $(basename "$0") [--source SOURCE] [--target TARGET] [--help]"
    echo " --source SOURCE"
    echo "       SOURCE specifies the directory that contains the files that should be built into an unattended install ISO. Defaults to the current directory"
    echo
    echo " --target TARGET"
    echo "       build the unattended install ISO at TARGET. Defaults to ${target_iso}"
    echo
    echo " --help"
    echo "       print this usage information and exit."
    echo
}

# This is the entry point for the script
main()
{
    source "$(dirname 0)/config.cfg"

    original_command_line="$*"                    # save original command line so it can be printed later (after cli parsing changes the args)

    uai_area="$(dirname $0)/bin/uai"                                                    # The files that make up the final UAI ISO
    
    unrecognised_option=0
    while [ $# -gt 0 ]
    do
	case "$1" in
	    -h|--help)
		usage
		exit 0
		;;
	    -s|--source)
		uai_area="$2"
		shift; shift # remove arg and value
		;;
	    -t|--target)
		target_iso="$2"
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

    mbr_bin="/usr/lib/ISOLINUX/isohdpfx.bin"
    if [ ! -f "${mbr_bin}" ]; then
	echo "Unable to locate required file ${mbr_bin} not present on system"
	echo "Perhaps try:"
	echo " sudo apt-get install --no-install-recommends -y isolinux"
	echo 
    fi

    if xorriso -as mkisofs \
               -isohybrid-mbr "${mbr_bin}" \
               -c isolinux/boot.cat \
               -b isolinux/isolinux.bin \
               -no-emul-boot \
               -boot-load-size 4 \
               -boot-info-table \
               -eltorito-alt-boot \
               -e boot/grub/efi.img \
               -no-emul-boot \
               -isohybrid-gpt-basdat \
               -o "${target_iso}" \
               "${uai_area}"; then
	# Tell the user where the ISO has been put
	echo "Unattended ISO: ${target}"
    fi
}

# Invoke the main script entry point
main
