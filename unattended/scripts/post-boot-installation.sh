#!/bin/bash
#
#
# This script is intended to execute once on the first boot of a newly
# installed system. It runs as a systemd service. It performs required
# post-install setup and then removes itself as a service.
#
# The real starting point is the main_actions function.


# This function cycles through a set of ansible scripts and invokes each in turn.
#
# $1, $2, ... $N: a set of ansible scripts to invoke 
#
run_ansible_playbooks() {
    for script in "$@"
    do
	echo "================================================================================"
	echo "          running ansible playbook ${script}"
	ansible-playbook  --connection=local -i 127.0.0.1, "/root/ansible/${script}"
	echo "================================================================================"
	echo "Playbook $1 completed"
    done
}


# This function tries to upgrade to a later kernel, starting with the most recent and working backwards by version,
# stopping when the candidate kernel is older than the currently installed kernel.
#
# This function is necessary as on at least one occasion attempting to install the latest kernel failed as no AMD build
# was available. That is likely to have been a transient condition, but an unattended procedure should at least try to
# work around such issues.
upgrade_kernel() {
    current_kernel=$(uname -r | sed 's/[-].*$//')
    mainline_kernel_script="$(dirname "$0")/ubuntu-mainline-kernel.sh"

    echo "Current kernel version: [${current_kernel}]"

    kernel_versions=$("${mainline_kernel_script}"  -r -q | tr -s '[:space:]'  '\n' | sed '1!G;h;$!d')

    local attempts=0

    for candidate in ${kernel_versions}
    do
	fixed_candidate=$(echo ${candidate} | sed 's/^v\(.*\)/\1/')
	if dpkg --compare-versions "${fixed_candidate}" "gt" "${current}"; then
	    echo "Attempting to install ${candidate} *******************"
	    if 	"${mainline_kernel_script}" -i "${fixed_candidate}" --yes; then
		echo "Installed kernel ${candidate} *******************"
		break
	    else
		echo "Failed to install kernel ${candidate}"
	    fi
	fi
	attempts=$((attempts + 1))
	if [ $attempts -ge 15 ]; then
	    echo "Abandoning kernel upgrade: Too many unsuccessful attempts ($attempts)"
	    break
	fi
    done
}

# This is the main entry point for this script.
main_actions() {
    this_script="$0"
    echo "Running ${this_script}"
    source "$(dirname "$0")/config.cfg"

    echo "================================================================================"
    echo "Preparing RTL8125 (via dkms)"
    "$(dirname "$0")/handle-r8125.sh" /root/r8125-dkms

    echo "================================================================================"
    echo "Preparing RTL8821CE (via dkms)"
    "$(dirname "$0")/handle-rtl8821ce.sh" /root/packages

    echo "================================================================================"
    echo "Performing apt update"
    apt-get update

    # Install required packages to allow ansible to run for further configuration
    PACKAGES=""
    PACKAGES="${PACKAGES} openssh-server"                # Needed to access this host via ssh
    PACKAGES="${PACKAGES} git"                           # Needed to access GitHub
    PACKAGES="${PACKAGES} python3"                       # Needed for ansible (probably already installed)
    PACKAGES="${PACKAGES} software-properties-common"    # Needed for ansible PPA
    echo "================================================================================"
    echo "Installing packages: [${PACKAGES}]"
    # Note: It has to be ${PACKAGES} here without double quotes otherwise apt-get treats
    # the whole string as a name for one package.
    apt-get install -y --no-install-recommends "${PACKAGES}"

    echo "================================================================================"
    echo "Downloading ansible playbooks"
    git clone https://github.com/AntonioCarlini/ansible /root/ansible

    # Install ansible
    # apt-add-repository --yes ppa:ansible/ansible # Does not seem to work on LM 20.1
    apt-get install -y --no-install-recommends ansible

    # Run suitable ansible scripts
    style=$(grep SYSTEM_CLASS /opt/unattended-install/env.proc1 | awk -F= '{print $2}')
    export SYSTEM_CLASS="${style}"
    as_minimal=""
    as_vmbase="vmware-host.yml"
    as_workstation="work-station.yml"
    export as_minimal       # keep shellcheck happy
    export as_vmbase        # keep shellcheck happy
    export as_workstation   # keep shellcheck happy
    v_name="as_${SYSTEM_CLASS}"
    ANSIBLE_SCRIPTS="${!v_name}"
    if [ -n "${ANSIBLE_SCRIPTS}" ]
    then
	echo "Running ansible scripts: [${ANSIBLE_SCRIPTS}]"
        run_ansible_playbooks "${ANSIBLE_SCRIPTS}"
    else
	echo "NO ansible scripts to run for [${SYSTEM_CLASS}]"
    fi

    # Update the package manager
    if [ "${apt_update}" = "1" ]; then
	echo "Updating apt repository information"
	apt-get update -y
    fi
    
    # Upgrade the system
    if [ "${software_upgrade}" = "1" ]; then
	echo "Updating installed software"
	apt-get upgrade -y
    fi

    # Upgrade to the latest available kernel
    if [ "${kernel_upgrade}" = "1" ]; then
	echo "Updating to latest available kernel"
	upgrade_kernel
    fi
    
    # Stop this from running again
    systemctl disable unattended-install.service

    rm "${this_script}"

    exit 0
}

# Invoke the main function.
main_actions >> /root/service.output 2>&1
