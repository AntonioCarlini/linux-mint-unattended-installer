# Usage

Note: this is still a WIP so the instructions may be out of date!

This is how to build an unattended install based on [Linux Mint 20.3](https://www.linuxmint.com/edition.php?id=292) from scratch.

- Prepare a work area and grab the [prepare script](https://github.com/AntonioCarlini/linux-mint-unattended-installer/blob/master/unattended/scripts/prepare-uai-area.sh).

        mkdir work_area
        cd work_area
        wget https://raw.githubusercontent.com/AntonioCarlini/linux-mint-unattended-installer/master/unattended/scripts/prepare-uai-area.sh
     
     

- Invoke the [prepare script](https://github.com/AntonioCarlini/linux-mint-unattended-installer/blob/master/unattended/scripts/prepare-uai-area.sh):

        chmod a+x prepare-uai-area.sh
        ./prepare-uai-area.sh --work-root .

- Invoke the script to build the required ISO file. Note that it is currently necessary to `cd` to the `env` directory first:

        cd env
        unattended/scripts/build-unattended-iso.sh

The result will be built as: `/tmp/mint-unattended.iso`.

# Notes

The initial menu contains a number of additional options in addition to those normally present in a Linux Mint ISO: 

- [Unattended Installer](#unattended-installer)
- [Unattended Installer (VM base)](#unattended-installer-vm-base)
- [Unattended Installer (Workstation)](#unattended-installer-workstation)

Each of these options is identical but passes a different value for the SYSTEM_CLASS environment variable through the command line. This value appears in the environment of the systemd process (pid 1) during the Live boot that installs the operating system on the HDD or SSD.

## Mandatory steps

The following steps are always carried out:

- Language is set to English.
- Country is set to UK.
- Keyboard is set to gb.
- The disk is partitioned for `/boot` `/` and `/home`.
- The `en_GB` locale is enabled and the `it_IT` and `jp_JP` locales are added as supported locales.
- The timezone is set to `Europe/Londo`n.
- An appropriate user is created.
- apt sources are prepared.
- apt is updated.
- openssh-server is installed.
- The post-reboot unattended-install service is configured in systemd.
- When the unattended-install service runs it installs the pre-requisites for ansible and then deletes itself.


## Unattended Installer

This is a minimal install with only the [mandatory steps](#mandatory-steps) carried out. This should leave a minimal system accessible over ssh.

## Unattended Installer (VM base)

In addition to the [mandatory steps](#mandatory-steps), the ansible playbook [vmware-host.yml](https://github.com/AntonioCarlini/ansible/blob/master/vmware-host.yml) is run.

## Unattended Installer (Workstation)

In addition to the [mandatory steps](#mandatory-steps), the ansible playbook [work-station.yml](https://github.com/AntonioCarlini/ansible/blob/master/work-station.yml) is run.
# Usage

Note: this is still a WIP so the instructions may be out of date!

This is how to build an unattended install based on [Linux Mint 20.3](https://www.linuxmint.com/edition.php?id=292) from scratch.

- Prepare a work area and grab the [prepare script](https://github.com/AntonioCarlini/linux-mint-unattended-installer/blob/master/unattended/scripts/prepare-uai-area.sh).

  mkdir work_area
  cd work_area
  wget https://raw.githubusercontent.com/AntonioCarlini/linux-mint-unattended-installer/master/unattended/scripts/prepare-uai-area.sh

- Invoke the script:

  chmod a+x prepare-uai-area.sh
  ./prepare-uai-area.sh --work-root .

- Invoke the script to build the required ISO file:

  cd env
  unattended/scripts/build-unattended-iso.sh

The result will be built as: /tmp/mint-unattended.sio.

# Notes

The initial menu contains a number of additional options in addition to those normally present in a Linux Mint ISO: 

- [Unattended Installer](#unattended-installer)
- [Unattended Installer (VM base)](#unattended-installer-vm-base)
- [Unattended Installer (Workstation)](#unattended-installer-workstation)

Each of these options is identical but passes a different value for the SYSTEM_CLASS environment variable through the command line. This value appears in the environment of the systemd process (pid 1) during the Live boot that installs the operating system on the HDD or SSD.

## Mandatory steps

The following steps are always carried out:

- Language is set to English.
- Country is set to UK.
- Keyboard is set to gb.
- The disk is partitioned for `/boot` `/` and `/home`.
- The `en_GB` locale is enabled and the `it_IT` and `jp_JP` locales are added as supported locales.
- The timezone is set to `Europe/Londo`n.
- An appropriate user is created.
- apt sources are prepared.
- apt is updated.
- openssh-server is installed.
- The post-reboot unattended-install service is configured in systemd.
- When the unattended-install service runs it installs the pre-requisites for ansible and then deletes itself.


## Unattended Installer

This is a minimal install with only the [mandatory steps](#mandatory-steps) carried out. This should leave a minimal system accessible over ssh.

## Unattended Installer (VM base)

In addition to the [mandatory steps](#mandatory-steps), the ansible playbook [vmware-host.yml](https://github.com/AntonioCarlini/ansible/blob/master/vmware-host.yml) is run.

## Unattended Installer (Workstation)

In addition to the [mandatory steps](#mandatory-steps), the ansible playbook [work-station.yml](https://github.com/AntonioCarlini/ansible/blob/master/work-station.yml) is run.
