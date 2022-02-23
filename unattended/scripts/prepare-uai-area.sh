#!/bin/bash
#
# This script constructs the environment required to build an unattended install ISO.
#
# !!! Note: --work-root is a WIP !!!
#
# Actually: first time require --work-root. After that assume to pof git tree and if that has *exactly* env, mnt and iso, use that.
#
# The first time this script runs it creates a work area (at WORK_ROOT):
#
#    ${WORK_ROOT}/iso is where the ISO will be downloaded
#    ${WORK_ROOT}/mnt is mountpoint for downloaded ISO
#    ${WORK_ROOT}/env is where the unattended install git repo will be cloned.
#    The contents of downloaded ISO will be copied to ${WORK_ROOT}/env, without overwriting any of the git repo files.
#
# Unless specified otherwise (with --work-root), the root will be assumed to be the current directory.
# Options:
#
# --repo-present
#   Indicates that the unattended install repository has already been cloned to the work area and should not be cloned again.
#   The repo will also not be updated.
#
# --source-iso-present
#   Indicates that the ISO that represents the starting point (i.e. the original Linux Mint ISO should not be downloaded again.
#
# --cleanup
#   Removes everything apart from the work area itself (for future tweaks) and the final unattended install ISO.
#
# --work-root WORK_ROOT
#   WORK_ROOT is where the work area for the process will be.
#
# --update
#   Update the unattended install repo and any downloaded repositories.
#
# --verbose
#   Write progress and debugging updates to stdout
#
# Work In progress

# Parse the permitted command line arguments.
parse_cli()
{
    original_command_line="$*"                    # save original command line so it can be printed later (after cli parsing changes the args)
    unrecognised_option=0

    while [ $# -gt 0 ]
    do
	  case "$1" in
	    -v|--verbose)
		verbose=1
		shift # remove arg
		;;
	    -r|--repo-present)
		uai_repo_present=1
		shift # remove arg
		;;
	    -s|--source-iso-present)
		iso_present=1
		shift # remove arg
		;;
	    -c|--cleanup)
		perform_cleanup=1
		shift # remove arg and value
		;;
	    -w|--work-root)
		work_root="$2"
		shift; shift # remove arg and value
		;;
	    -u|--update)
		perform_update=1
		shift # remove arg
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

# If requested, clone the git repo to ${uai_area}.
# Exit the script is this fails for any reason.
#
# $1 if 0, the repo should be created (cloned) or updated (pulled)
#    otherwse nothing should be done
#
# $2 if  0, clone the repo
#    otherwise use 'git pull' to update the repo
prepare_unattended_install_repo()
{
    if [ "$1" == "0" ]; then
	if [ "$2" == "0" ]; then
	    if ! git clone "${uai_repo}" "${uai_area}"; then
		echo "Failed to clone the repo to ${uai_area}"
		exit 1
	    fi
	else
	    if ! git pull; then
		echo "Failed to update the unattended install repo"
		exit 2
	    fi
	fi
    fi

    # Remove some text files from the repo that do not really belong on the ISO
    for file in "${uai_area}/LICENSE" "${uai_area}/README.md"
    do
	if [ -f "${file}" ]; then
	    rm "${file}"
	fi
    done
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

    # ${uai_area} must be empty if it exists

    # ${mountpoint} must be empty if it exists
}

# Download the dkms debian package
add_packages()
{
    mkdir -p "${uai_area}/unattended/packages"
    ( \
      cd "${uai_area}/unattended/packages" || return; \
      apt-get download dkms; \
    )
}

add_repositories()
{
    mkdir -p "${uai_area}/unattended/repositories"
    ( \
      cd "${uai_area}/unattended/repositories" || return; \
      git clone https://github.com/PyCoder/r8125-dkms \
    )
}


# Finds the work root if this is not the first run of this script.
# Set the variable work_root to the root if found or to an empty string if not.
#
# If work_root is not blank, then do nothing.
# To find the work root, assume that the CWD is a git repo and find it's root.
# If it is not a git repo, then return a blank string.
# If it is a git repo, then go one level up from the git root.
# If that contains the subdirectories iso, mnt and env *and nothing else* then that is the work root.
find_work_root()
{
    # If work_root already has a value, don't touch it.
    if [ ! -z "${work_root}" ]; then
       return 1
    fi

    if local git_top=$(git rev-parse --show-toplevel 2> /dev/null); then
	local putative_root=$(cd "${git_top}/.."; pwd)
	for file in "${putative_root}"/*; do
	    case "${file}" in
		"${putative_root}"/env) ;;
		"${putative_root}"/mnt) ;;
		"${putative_root}"/iso) ;;

		*)
		    exit 1
	    esac
	done
    fi
		    
    # If we get this far, then we have our work root
    work_root="${putative_root}"
}

#+
# The main script starts here
#-
verbose=0                                                               # Keep verbosity low
uai_repo_present=0                                                       # If non-zero, the unattended install git repo is already present and should not be cloned
perform_cleanup=0                                                       # If non-zero, clean down intermediate results
perform_update=0                                                        # If non-zero, update where required
uai_repo="https://github.com/AntonioCarlini/linux-mint-unattended-installer"         
lm_download_url_prefix="http://www.mirrorservice.org/sites/www.linuxmint.com/pub/linuxmint.com/stable/"
source_iso_name="linuxmint.iso"
lm_version="20.3"

work_root=""

parse_cli "$@"             # Parse cli to allow overrides

find_work_root             # Find work_root

if [ -z "${work_root}" ]; then
    echo "No work_root found or specified."
    echo "Either specify a work_root or run within the env subriectory of a previously initialised work_root"
    exit 1
fi

# Set variables that might depend on the arguments passed in by the CLI
source_iso_download_dir="${work_root}/iso"
mountpoint="${work_root}/mnt"
uai_iso_name="${work_root}/mint-unattended.iso"
uai_area="${work_root}/env"

# Check environment - will abort if any error is found
check

# Create the necessary directories, if required
mkdir -p "${uai_area}"
mkdir -p "${mountpoint}"
mkdir -p "${source_iso_download_dir}"

prepare_unattended_install_repo "${uai_repo_present}" "${perform_update}"      # Download the unattended install repo to source area
add_packages                                                                   # Download packages
add_repositories                                                               # Download 3rd party repositories

# Download specified Linux Mint ISO (unless already present) and loop mount
wget -nc "${lm_download_url_prefix}/${lm_version}/linuxmint-${lm_version}-cinnamon-64bit.iso" -O "${source_iso_download_dir}/${source_iso_name}"
sudo mount -o ro,loop "${source_iso_download_dir}/${source_iso_name}" "${mountpoint}"

# Copy ISO over scratch area, but do not overwite existing files (from the git unattended install repo).
# Do not specify any files from the source otherwise hidden directories (such as .disk) will be missed and the final ISO will not function correctly.
# (An alternative would be some kind of union mount)
cp -v -nRT "${mountpoint}" "${uai_area}"

# Unmount the source ISO
sudo umount "${mountpoint}"

# Build the pre-seeded ISO (TODO)
# "${uai_area}"/unattended/scripts/build-unattended-iso.sh --source "${uai_area}" --target "${uai_iso_name}"

# Cleanup.
if [ ${perform_cleanup} -ne 0 ]; then
    rmdir "${mountpoint}"
    rmdir "${source_iso_download_dir}"
fi
