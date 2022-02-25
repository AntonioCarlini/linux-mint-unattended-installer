#!/bin/bash
#
# This script decides whether to install a driver for the Realtek RTL8821CE PCIe Wireless Network Adapter.
# This is needed (for example) for the HP Notebook 15-db0997n.
#

# Look for the RTL8821CE Realtek Ethernet controller and stop if it is not present.
if ! lspci | grep RTL8821CE; then
    echo "No Realtek RTL8821CE PCIe Wireless Network Adapter hardware found."
    exit
fi

# Install the RTL8821CE driver package (which uses DKMS)
pkg=$(basename $(find  "$1" -name "*rtl8821ce-dkms*"))
(cd "$1"; dpkg -i "./${pkg}")

# Force the module to load immediately
modprobe rtl8821ce
