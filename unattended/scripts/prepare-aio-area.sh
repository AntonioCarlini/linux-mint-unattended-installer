#!/bin/sh
#
# This script constructs the environment required to build an AIO (all-in-one) unattended ISO.
#
# Options:
#
# --aio-repo-present
#   Indicates that the AIO repository has already been cloned to the work area and should not be cloned again.
#
# --source-iso-present
#   Indicates that the ISO that represents the starting point (i.e. the original Linux Mint ISO should not be downloaded again.
#
# --cleanup
#   Removes everything apart from the work area itself (for future tweaks) and the final AIO ISO.
#
# Work In progress

# Parse the permitted command line arguments.
parse_cli()
{
    unrecognised_option=0
    while [ $# -gt 0 ]
    do
	case "$1" in
	    -r|--aio-repo-present)
		aio_repo_present=1
		shift # remove arg
		;;
	    -s|--source-iso-present)
		iso_present=1
		shift # remove arg and value
		;;
	    -c|--cleanup)
		perform_cleanup=1
		shift # remove arg and value
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
	exit 2
    fi

}

# If requested, clone the git repo to ${aio_area}.
# exit the script is this fails for any reason.
prepare_aio_repo()
{
    if [ ${aio_repo_present} -eq 0 ]; then
	git clone "${aio_repo}" "${aio_area}"
	result=$?
	if [ "${result}" != "0" ]; then
	    echo "Failed to clone the repo to ${aio_area}"
	    exit 1
	fi
    fi

    # Remove some text files from the repo that do not really belong on the ISO
    rm "${aio_area}/LICENSE"
    rm "${aio_area}/README.md"
}

# Display a message with instructions on how to use this procedure
usage()
{
    echo "Usage: `basename "$0"` TBD"
}

# Verify that the requested environment appears to be valid
check()
{
    echo "TODO: Perform checks"

    # ${aio_area} must be empty if it exists

    # ${mountpoint} must be empty if it exists
}

# Download the dkms debian package
add_packages()
{
    mkdir "${aio_area}/unattended/packages"
    ( \
      cd "${aio_area}/unattended/packages"; \
      apt-get download dkms; \
    )
}

add_repositories()
{
    mkdir "${aio_area}/unattended/repositories"
    ( \
      cd "${aio_area}/unattended/repositories"; \
      git clone https://github.com/PyCoder/r8125-dkms \
    )
}

aio_repo_present=0                                                       # If non-zero, the AIO git repo is already present and should not be cloned
perform_cleanup=0
aio_repo="https://github.com/AntonioCarlini/linux-mint-aio"         
lm_download_url_prefix="http://www.mirrorservice.org/sites/www.linuxmint.com/pub/linuxmint.com/stable/"
source_iso_name="linuxmint.iso"
lm_version="20.1"

work_root="/tmp/aio-new"
aio_area="/tmp/aio-new/env"

# Parse cli to allow overrides
parse_cli "$@"

source_iso_download_dir="${work_root}/iso"
mountpoint="${work_root}/mnt"
aio_iso_name="${work_root}/mint-aio.iso"

# Check environment - will abort if any error is found
check

# Create the necessary directories, if required
mkdir -p "${aio_area}"
mkdir -p "${mountpoint}"
mkdir -p "${source_iso_download_dir}"

# Download the AIO repo to source area
prepare_aio_repo
add_packages
add_repositories

# Download specified Linux Mint ISO (unless already present) and loop mount
wget -nc "${lm_download_url_prefix}/${lm_version}/linuxmint-${lm_version}-cinnamon-64bit.iso" -O "${source_iso_download_dir}/${source_iso_name}"
mount -o ro,loop "${source_iso_download_dir}/${source_iso_name}" "${mountpoint}"

# Copy ISO over scratch area, but do not overwite existing files (from the git AIO repo).
# Do not specify any files from the source otherwise hidden directories (such as .disk) will be missed and the final ISO will not function correctly.
# (An alternative would be some kind of union mount)
cp -nRT "${mountpoint}" "${aio_area}"

# Unmount the source ISO
umount "${mountpoint}"

# Build the pre-seeded ISO (TODO)
# "${aio_area}"/unattended/scripts/build-unattended-iso.sh --source "${aio_area}" --target "${aio_iso_name}"

# Cleanup.
if [ ${perform_cleanup} -ne 0 ]; then
    rmdir "${mountpoint}"
    rmdir "${source_iso_download_dir}"
fi



# Notes for further development:
# future options:
# --iso-mount
# --scratch
# --aio-iso
# --keep-iso
# --keep-scratch
