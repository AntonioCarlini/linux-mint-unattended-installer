#Usage

This is how to build an unattended install based on Linux Mint 20.1.

- Download the Linux Mint ISO:

`wget -O /tmp/linux-mint.iso http://www.mirrorservice.org/sites/www.linuxmint.com/pub/linuxmint.com/stable/20/linuxmint-20-cinnamon-64bit.iso`

- Loop mount it:

`mkdir -p /tmp/mint-iso`
`mount -o loop /tmp/linux-mint.iso /tmp/mint-iso`

- Prepare the repo:

`git clone https://github.com/AntonioCarlini/linux-mint-aio /tmp/aoi2`

- Copy the ISO over the repo, without overwriting any files:

`cp -Ri /tmp/mint-iso/* /tmp/aoi2/.`

- Invoke the script to build the required ISO file:

`/tmp/aio2/unattended/scripts/build-unattended-iso.sh`

The result will be: `/tmp/linux-mint-20.1-unattended-install.iso`.

#Notes

The initial menu contains a number of additional options in addition to those nomally present in a Linux Mint ISO: 
 - [Unattended Installer](Unattended Installer)
 - [Unattended Installer (VM base)](Unattended Installer (VM base))
 - [Unattended Installer (Workstation)](Unattended Installer (Workstation))

Each of these options is identical but passes a different value for the SYSTEM_CLASS environment variable through the command line. This value appears in the environment of the systemd process (pid 1) during the Live boot that installs the operating system on the HDD or SSD.

##Mandatory steps

The following steps are always carried out:
Language is set to English.
Country is set to UK.
Keyboard is set to gb.
The disk is partitioned for /boot / and /home.
The en_GB locale is enabled and the it_IT and jp_JP locales are added as supported locales.
The timezone is set to Europe/London.
An appropriate user is created.
apt is prepared.
apt is updated.
openssh-server is installed.
The post-reboot unattended-install service is configured in systemd.
When the unattended-install service runs it installs the pre-requisites for ansible and then deletes itself.


##Unattended Installer

This is a minimal install with only the mandatory steps carried out. This should leave a minimal system accessible over ssh.

##Unattended Installer (VM base)

In addition to the mandatory steps, the ansible playbook vmware-host.yml is run.

##Unattended Installer (Workstation)

In addition to the mandatory steps, the ansible playbook work-station.yml is run.

