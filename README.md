# Arch Linux installation via Ansible

This project implements with [Ansible](https://docs.ansible.com/ansible/latest/index.html)
the automated basic Arch Linux installation described in the
[Arch Linux Wiki](https://wiki.archlinux.org/index.php/installation_guide).

The installation is performed from another machine on the same local network.

The installation involves the following steps:

1. Boot the machine to be installed with the [Arch Linux ISO](https://archlinux.org/download/).
   The machine connects to the local network.
2. Start a sshd server and allow ssh root remote connections with a ssh key
   configured on a github account. This is done by executing a shell script
   downloaded from this repository.
3. From an installation machine on which this project has been cloned, perform
   the installation.
4. Reboot the machine.

## Default configuration

Upon installation, the installed machine only contains a basic installation with
a sshd server and a bastion user account (`arch` by default).

By default, the installed machine has the following features (look
[below](#customization) for customization):

- A Bios boot partition of 1 MByte.
- An UEFI partition of 300 Mbytes.
- A Swap partition of 1 Gbyte.
- An ext4 root partition covering the rest of the installation volume.
- The hostname is `arch`.
- The unique user is named `arch`.
- The unique user has no password.
- The unique user is sudoer without password.
- The network is configured on `eth0` with DCHP via
  [systemd-networkd](https://wiki.archlinux.org/index.php/systemd-networkd).

- Time is synchronized with [systemd-timesyncd](https://wiki.archlinux.org/index.php/Systemd-timesyncd)
- Name resolution is done through [systemd-resolved](https://wiki.archlinux.org/index.php/Systemd-resolved)
- A sshd server is launched at boot.
- The bootloader is grub and works either on BIOS and on UEFI. UEFI installation
  is only performed if the installation medium has been booted in uefi mode.

## Pre-requisisites

This project assumes that the machine to be installed is connected to the local
network on the first wired interface (`eth0`).

The installation is performed from another machine connected to the same
network. Clone this project on this machine and install ansible with the
following:

```console
> git clone https://github.com/antoinemartin/archlinux-ansible-install.git
> cd archlinux-ansible-install
> python3 -mvenv env
> source env/bin/activate
(env) > pip install ansible
(env) > _
```

On archlinux you may want to use the ansible package:

```console
> sudo pacman -S ansible
```

## Installation instructions

Perform the [Pre-installation](https://wiki.archlinux.org/index.php/installation_guide#Pre-installation)
instructions of the Archlinux install guide up to [Connect to the internet](https://wiki.archlinux.org/index.php/installation_guide#Connect_to_the_internet)
that involves:

- [Download](https://archlinux.org/download/) the installation image.
- Prepare the installation medium either on [USB or SD Card](https://wiki.archlinux.org/index.php/USB_flash_installation_medium)
  or [PXE](https://wiki.archlinux.org/index.php/Preboot_Execution_Environment)
- Boot the machine on the ISO.

On the login prompt, the first thing you may want to do is set the keyboard:

```console
root@archiso ~ # loadkeys fr
root@archiso ~ # _
```

And check your network connection:

```console
root@archiso ~ # ip route get 1
1.0.0.0 192.168.0.1 dev ens33 src 192.168.0.238 uid 0
root@archiso ~ # _
```

Before performing the installation from the development machine you need to:

- Start the ssh server,
- Allow remote connections with some ssh key.

The [archinstall_seed.sh](archinstall_seed.sh) script on this project does this.
It takes the ssh public key from a github account.
You can specify your own account by setting the
`ARCHINSTALL_SSH_KEY_GITHUB_ACCOUNT` variable before running the script:

```console
root@archiso ~ # export ARCHINSTALL_SSH_KEY_GITHUB_ACCOUNT=antoinemartin
root@archiso ~ # source <(curl -Ls https://raw.githubusercontent.com/antoinemartin/archlinux-ansible-install/archinstall_seed.sh)
Installing ssh key
Starting ssh...

Now you can connect with ssh root@192.168.0.238

To install this machine, on your development machine do the following:

$ export ARCHINSTALL_SSH_KEY_GITHUB_ACCOUNT=antoinemartin
$ export ARCHINSTALL_IP_ADDRESS=192.168.0.238
$ export ARCHINSTALL_SSH_KEY=$HOME/.ssh/antoinemartin.key # (Optional. Or ssh-add key)
$ export ARCHINSTALL_HOSTNAME=...        # (Optional. arch by default)
$ export ARCHINSTALL_USERNAME=...        # (Optional. arch by default)
$ export ARCHINSTALL_PASSWORD=...        # (Optional. No password by default)
$ ansible-playbook install_archlinux.yaml

If you want to restart from scratch, run the following commands here before:

$ wipefs --all /dev/sda
$ sfdisk --delete all /dev/sda

root@archiso ~ # _
```

Check the ssh connection from your development machine:

```console
$ ssh -i ~/.ssh/antoinematin.dsa root@192.168.0.238
To install Arch Linux follow the installation guide:
https://wiki.archlinux.org/index.php/Installation_guide

For Wi-Fi, authenticate to the wireless network using the iwctl utility.
Ethernet and Wi-Fi connections using DHCP should work automatically.

After connecting to the internet, the installation guide can be accessed
via the convenience script Installation_guide.

Last login: Sun Jan  3 11:26:42 2021 from 192.168.0.64
root@archiso ~ # exit
$ _
```

You can then perform the installation:

```console
$ export ARCHINSTALL_SSH_KEY_GITHUB_ACCOUNT=antoinemartin
$ export ARCHINSTALL_IP_ADDRESS=192.168.0.238
$ export ARCHINSTALL_SSH_KEY=$HOME/.ssh/antoinemartin.dsa
$ ansible-playbook install_archlinux.yaml
...
```

The installation will be performed. Upon completion, you can restart the machine
and connect to it via ssh:

```console
$ ssh -i ~/.ssh/antoinemartin.dsa arch@arch
Warning: Permanently added 'arch,192.168.0.61' (ECDSA) to the list of known hosts.
Last login: Sun Jan  3 13:04:16 2021 from 192.168.0.64
arch@arch:~ >
```

## Customization

Customization is described in [the role README
file](roles/system_archlinux_install/README.md).

The following elements can be configured:

- The presence of a swap partition (`-e has_swap=yes`).
- The host name of the machine (`arch` by default).
- The entry user name (`arch` by default).
- The password for the user. By default, the user has no password and the login
  can only be performed through ssh.
- The bootloader. It can either be [GRUB](https://wiki.archlinux.org/index.php/GRUB)
  or [Systemd-boot](https://wiki.archlinux.org/index.php/systemd-boot). The
  later doesn't need a specific package installation and is the default. The
  former offers much more options (BIOS **and** UEFI).
- The presence of a swap file.

## Development

This is a small Ansible project containing:

- a one machine inventory in the [inventory](inventory) file.
- a role named `system_archlinux_install` performing the intallation. This role
  is contained in the `roles` directory.
- A playbook in the file [install_archlinux.yaml](install_archlinux.yaml) performing the role on the `archlinux` host.
- A simple [ansible.cfg](ansible.cfg) Ansible configuration.

Development and adapation of the role can be done on a Virtual Machine. It has
been successfully tested on VMware and xhyve, but the most portable
virtualization solution is probably [qemu](https://qemu.org).

You can create a _test disk_ with the following command:

```console
❯ qemu-img create -f raw arch.img 10G
```

To launch a virtual machine in UEFI, you need an UEFI firmware. You can grab an
already compiled version for instance [here](https://github.com/clearlinux/common/blob/master/OVMF.fd).

And then launch the test virtual machine with:

```console
> qemu-system-x86_64 \
   -vga virtio \
   -machine type=q35,accel=hvf \
   -m 1024 \
   -device virtio-net-pci,netdev=net0 \
   -netdev 'user,id=net0,hostfwd=tcp::5555-:22,guestfwd=tcp:10.0.2.100:80-cmd:nc localhost 8000' \
   -hda arch.img \
   -bios OVMF.fd \
   -cdrom ./archlinux-2021.01.01-x86_64.iso
```

The `guestfwd=tcp:10.0.2.100:80-cmd:nc localhost 8000` allows you to fetch the
`archinstall_seed.sh` locally by running on your development server:

```console
> python3 -mhttp.server
```

And on the virtual machine:

```console
root@archiso ~ # /bin/bash -c "$(curl -Ls http://10.0.2.100/archinstall_seed.sh)
Installing ssh key
Starting ssh...

Now you can connect with ssh root@10.0.2.15

To install this machine, on your development machine do the following:

$ export ARCHINSTALL_SSH_KEY_GITHUB_ACCOUNT=antoinemartin
$ export ARCHINSTALL_IP_ADDRESS=10.0.2.15
$ export ARCHINSTALL_SSH_KEY=$HOME/.ssh/antoinemartin.key # (Optional. Or ssh-add key)
$ export ARCHINSTALL_HOSTNAME=...        # (Optional. arch by default)
$ export ARCHINSTALL_USERNAME=...        # (Optional. arch by default)
$ export ARCHINSTALL_PASSWORD=...        # (Optional. No password by default)
$ ansible-playbook install_archlinux.yaml

If you want to restart from scratch, run the following commands here before:

$ wipefs --all /dev/sda
$ sfdisk --delete all /dev/sda

root@archiso ~ # _
```

Now you can perform the installation with:

```console
> # On the host
> export ARCHINSTALL_IP_ADDRESS=127.0.0.1
> export ARCHINSTALL_SSH_PORT=5555
> ansible-playbook install_archlinux.yaml
```

Reboot the virtual machine without the CD ROM:

```console
> qemu-system-x86_64 \
   -vga virtio \
   -machine type=q35,accel=hvf \
   -m 1024 \
   -device virtio-net-pci,netdev=net0 \
   -netdev user,id=net0,hostfwd=tcp::5555-:22 \
   -hda arch.img \
   -bios OVMF.fd
```

Once booted, you can connect through the forwarded port:

```console
❯ ssh -i ~/.ssh/antoinemartin.dsa -p 5555 arch@localhost
Warning: Permanently added '[localhost]:5555' (ECDSA) to the list of known hosts.
Last login: Wed Jan  6 15:38:56 2021 from 10.0.2.2
arch@arch:~ > _
```

And you can also reboot without the `-bios` option to test in BIOS mode:

```console
> qemu-system-x86_64 \
   -vga virtio \
   -machine type=q35,accel=hvf \
   -m 1024 \
   -device virtio-net-pci,netdev=net0 \
   -netdev user,id=net0,hostfwd=tcp::5555-:22 \
   -hda arch.img
```

## Alternatives

For virtual machines, [packer-arch] provides a similar configuration.
