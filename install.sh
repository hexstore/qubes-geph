#!/bin/bash
# Install packages on the target qube.

set -eux pipefail

REMOTE="https://git.sr.ht/~qubes/geph/blob/main"
WORKDIR="${HOME}/.local/geph"
mkdir -p "${WORKDIR}"

cd "${WORKDIR}"

curl --proto '=https' -tlsv1.2 -sSfL "${REMOTE}/restrict-firewall" -o restrict-firewall
curl --proto '=https' -tlsv1.2 -sSfL "${REMOTE}/geph.service" -o geph.service
curl --proto '=https' -tlsv1.2 -sSfL "${REMOTE}/geph" -o geph

sudo install -Dm755 -t /rw/usrlocal/bin "${WORKDIR}/geph"
sudo install -Dm755 -t /rw/usrlocal/bin "${HOME}/QubesIncoming/geph-builder/geph4-client"
sudo install -Dm755 -t /rw/config/qubes-firewall.d "${WORKDIR}/restrict-firewall"
sudo cp /rw/config/rc.local /rw/config/rc.local.old

set +x
sleep 1
while [ -z "${username:+x}" ]; do
  echo -n "Enter geph username: "
  read -r username
done
echo -n "Enter geph password: "
read -r password
sleep 1
set -x

sudo sed -i "s/<USERNAME>/${username}/" /rw/usrlocal/bin/geph
sudo sed -i "s/<PASSWORD>/${password}/" /rw/usrlocal/bin/geph

echo 'cp /home/user/.local/geph/geph.service /etc/systemd/system/geph.service' | sudo tee -a /rw/config/rc.local
echo 'systemctl --no-block restart geph.service' | sudo tee -a /rw/config/rc.local
