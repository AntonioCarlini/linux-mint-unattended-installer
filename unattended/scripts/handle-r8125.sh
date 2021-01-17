#!/bin/bash
#
# This script decides whether extra measures need to be taken to load the RTL8125 ethernet driver.
# It also waits briefly for an IP address to become available (presumably via DHCP) so that anything
# that comes after this script has a chance of having network connectivity available.
#
# $1: The directory containing the r8125 install script.
#

# Look for the RTL8125 Realtek Ethernet controller and stop if it is not present.
if ! lspci | grep RTL8125; then
    echo "No Realtek RTL8125 Ethernet Hardware found."
    exit
fi

# If the module is already loaded, no need for further action
if lsmod | grep r8125; then
    echo "Realtek RTL8125 module already loaded."
    exit
fi

# Try to load the r8125 module (via dkms)
( cd "$1" || exit; ./install.sh )

# Wait (for a limited time) for an IP address to be available

ipaddr_wait_seconds=30
start_epoch=$(date +%s)
end_epoch=$((start_epoch + ipaddr_wait_seconds))
while [ "${end_epoch}" \> "$(date +%s)" ]
do
    addr=$(hostname -I)  # excludes loopback and IPv6 link local addresses
    if [ ! -z "${addr}" ]; then
	echo "Stopping waiting as have found address ${addr}"
	break
    fi
    sleep 1
done

# Give everything a chance to settle down before finishing
sleep 4
echo "$((basename $0)) finished"
