# This script is to be used while installing an archnlinux machine with the 
# following command:
# source <(curl -Ls https://raw.githubusercontent.com/antoinemartin/archlinux-ansible-install/archinstall_seed.sh)
echo "Installing ssh key"
install -m 700 -d /root/.ssh
github_account="${ARCHINSTALL_SSH_KEY_GITHUB_ACCOUNT:-antoinemartin}"
curl -s "https://api.github.com/users/${github_account}/keys" | python -c 'import json,sys;print(json.load(sys.stdin)[0]["key"])' >/root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
echo "Starting ssh..."
systemctl enable --now sshd
my_ip=`ip route get 1 | awk '{print $(NF-2);exit}'`
if [ -b /dev/mmcblk1 ]; then
  mmcdoc=$(echo "$ export ARCHLINSTALL_MMC=yes")
  device=mmcblk1
else
  mmcdoc=""
  device=sda
fi
cat << EOF

Now you can connect with ssh root@$my_ip

To install this machine, on your development machine do the following:

${mmcdoc}$ export ARCHINSTALL_SSH_KEY_GITHUB_ACCOUNT=$github_account
$ export ARCHINSTALL_IP_ADDRESS=$my_ip
$ export ARCHINSTALL_SSH_KEY=\$HOME/.ssh/${github_account}.key # (Optional. Or ssh-add key)
$ export ARCHINSTALL_HOSTNAME=...        # (Optional. arch by default)
$ export ARCHINSTALL_USERNAME=...        # (Optional. arch by default)
$ export ARCHINSTALL_PASSWORD=...        # (Optional. No password by default)
$ ansible-playbook install_archlinux.yaml

If you want to restart from scratch, run the following command here before:

$ wipefs --all /dev/$device
$ sfdisk --delete all /dev/sda

EOF
