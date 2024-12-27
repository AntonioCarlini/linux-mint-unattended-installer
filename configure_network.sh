#!/bin/bash
#
# Script that, if required, will reconfigure the network
#
# Depends on the following variables from config.cfg:
#
# configure_ipv4: set to 1 to cause reconfiguration, otherwise nothing is done
# ipv4_method:    set to manual to configure a static IP address
# ipv4_gateway    IP address of the gateway
# ipv4_address    host IP address
# ipv4_dns_servers:  a list of DNS server IP addresses, separated by spaces; the whole list in double quotes
#

# Pick up variables from config.cfg
source "$(dirname "$0")/config.cfg"

# 
main_actions() {
    if [ "${configure_ipv4}" != "1" ]; then
	echo "No IPv4 configuration changes requested"
	exit 0
    fi
    echo "Reconfiguring IPv4 network"

    parameters_ok="Y"
    for param in ipv4_method ipv4_gateway ipv4_address ipv4_dns_servers
    do
	if [ "${!param}" = "" ]; then
	    echo "Missing mandatory configuration parameter: '${param}'"
	    parameters_ok="N"
	fi
    done
    if [ "${parameters_ok}" != "Y" ]; then
	echo "ERROR: One or more mandatory configuration parameters missing"
	exit 1
    fi

    # Count number of ethernet interfaces present.
    # Note that we need to exclude such things as docker and VM interfaces.
    # Expected command output should look like:
    # Wired connection 1:ed633cd1-f840-350a-8a67-ea9aceb1c5f6:802-3-ethernet:ens33
    eth_interfaces=$(nmcli --terse con show  | grep 802-3-ethernet)

    ethint=$(echo ${eth_interfaces} |  wc -l)
    if [ "${ethint}" != "1" ]; then
	"ERROR: Unable to configure if more than one interface is present; found ${ethint} interfaces"
	exit 2
    fi
    
    # Find the name of the network connection that needs to be reconfigured
    connection=$(echo ${eth_interfaces} | cut -d: -f1)

    echo "nmcli con mod \"${connection}\" ipv4.addresses ${ipv4_address}/24"
    echo "nmcli con mod \"${connection}\" ipv4.gateway ${ipv4_gateway}"
    echo "nmcli con mod \"${connection}\" ipv4.dns ${ipv4_dns_servers}"
    echo "nmcli con mod \"${connection}\" ipv4.method manual"
    echo "nmcli con up \"${connection}\" "

}

# Invoke the main function.
main_actions

