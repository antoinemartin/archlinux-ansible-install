# Install Archlinux role

This role installs Arch Linux on a Physical or Virtual machine. The installation
is basic and performs the following:

- Partition the first block device. It can either be a classical block device
  (`/dev/sda`) or an emmc device (`/dev/mmcblk1`).
- Install Arch Linux on it through `pacstrap`
- Make a basic configuration of the system (network, ssh, ..).
- Create a bastion user (`arch` by default) that is an ssh sudo entry point.
- Install a bootloader (`grub` by default).

## Requirements

This roles assumes that the machine has been booted on a Arch Linux
installation medium, that it is accessible from the local network and that a ssh
connection can be performed either to the root account or to an account that is
a sudoer without password.

In particular, a working python 3 interpreter shoud be available on the
destination machine as well as the `arch-install-scripts` package.

## Role Variables

The following variables are available:

| Name                               | Default value                        | EnvVar                               | Description                                              |
| ---------------------------------- | ------------------------------------ | ------------------------------------ | -------------------------------------------------------- |
| `mmc`                              | `'no'`                               | `ARCHINSTALL_MMC`                    | Wether the block device is EMMC                          |
| `install_device_name`              | `/dev/mmcblk1` for mmc or `/dev/sda` | -                                    | Device on which to install the system                    |
| `state`                            | `present`                            | -                                    | `present` or `absent`                                    |
| `has_swap`                         | `yes`                                | -                                    |                                                          |
| `swap_size`                        | `1Gib`                               | -                                    | Swap size with sfdisk format                             |
| `archlinux_hostname`               | `arch`                               | `ARCHINSTALL_HOSTNAME`               |                                                          |
| `archlinux_username`               | `arch`                               | `ARCHINSTALL_USERNAME`               |                                                          |
| `archlinux_password`               | `-`                                  | `ARCHINSTALL_PASSWORD`               |                                                          |
| `archlinux_shell`                  | `/bin/zsh`                           | -                                    | Shell to use for bastion user. `/bin/zsh` or `/bin/bash` |
| `archlinux_ssh_key_github_account` | `antoinemartin`                      | `ARCHINSTALL_SSH_KEY_GITHUB_ACCOUNT` |                                                          |
| `archlinux_ssh_key`                | See below                            | -                                    | SSH Key to use for bastion user                          |
| `archlinux_locale`                 | `en_US.UTF-8`                        | -                                    | Main locale                                              |
| `archlinux_additional_locale`      | `fr_FR.UTF-8`                        | -                                    | Additional locale to generate with locale-gen            |
| `archlinux_timezone`               | `Europe/Paris`                       | -                                    | Default timezone                                         |
| `archlinux_keymap`                 | `fr`                                 | -                                    | Default keymap                                           |
| `archlinux_ntp_country`            | `fr`                                 | -                                    | ntp.org country to use for time synchronization          |
| `base_packages`                    | See below                            | -                                    | Base packages to install                                 |
| `grub_packages`                    | See below                            | -                                    | Packages to install when grub bootloader is used         |
| `zsh_packages`                     | See below                            | -                                    | Base packages to install when zsh is used                |
| `install_bootloader`               | `yes`                                | -                                    | Whether to install a boot loader                         |
| `bootloader`                       | `grub`                               | -                                    | `systemd-boot` or `grub`                                 |
| `bootloader_nvram`                 | `yes`                                | -                                    | Persist bootloader on nvram                              |
| `boot_dirname`                     | `/boot`                              | -                                    | Name of directory holding the efi partition              |
| `root_mountdir`                    | `/mnt`                               | -                                    | Where to boot the partitions created                     |

### Machine partitions

The partitions are deduced from `mmc` and `install_device_name`. If `mmc` is
`yes`, the default install_defice is `/dev/mmcblk1` and install partitions will
contains an additional `p` character, i.e. `/dev/mmcblk1p1`. If the installation
device is not EMMC, the default value is `/dev/sda` and the partitions will have
the normal scheme, i.e. `/dev/sda1`.

In any case, the first partition (`/dev/mmcblk1p1` or `/dev/sda1`) is the EFI
special partition and the last partition is the root partition. If `has_swap` is
`yes`, a second (`/dev/mmcblk1p2` or `/dev/sda2`) swap partition is created.

### Bastion user SSH Key

The bastion user (`arch` by default) ssh public key is contained in the
`archlinux_ssh_key` variable. If not overwritten, the value for this variable is
downloaded from the github account pointed by the
`archlinux_ssh_key_github_account` variable. The first key of the account is
taken.

### Packages to install

The packages installed on the machine are given by the `base_packages` variable.
Some additional packages are added to this list. The ones in the `grub_packages`
list are added if GRUB is used as the boot loader (`bootloader` is `grub`).
Packages in the `zsh_packages` list are added if `zsh` is the shell bastion
(the default).

### Bootloader

By default, GRUB is installed both in UEFI mode and BIOS mode. This allows using
a dump/backup of the installed disk on other hardware or with various
virtualization solutions.

If the bootloader is `systemd-boot`, only UEFI is available.

In UEFI, setting the `bootloader_nvram` variable to `no` prevents insertion of
the created boot option (`grub` or `Linux`) in the current hardware. This is
useful when performing an installation on a virtual environment.

## Dependencies

None.

## Example Playbook

The following is the content of the `install_archlinux.yml` playbook:

```yaml
---
- name: Base install
  tags: base_install
  hosts: archlinux
  gather_facts: yes
  roles:
    - role: system_archlinux_install
```

The following is the same playbook with some customization:

```yaml
---
- name: Base install
  tags: base_install
  hosts: archlinux
  gather_facts: yes
  vars:
    archlinux_hostname: aron
    archlinux_username: antoine
    swap_size: 2Gib
    archlinux_ssh_key: "{{ lookup('file', "~/.ssh/antoinemartin.pub") }}"
  roles:
    - role: system_archlinux_install
```

## License

Copyright (C) 2020 Unowhy. All rights reserved.

## Author Information

[Antoine Martin](mailto:amartin@unowhy.com). More documentation available at
https://github.com/antoinemartin/archnlinux-ansible-install
