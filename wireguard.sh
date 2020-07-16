## Needs to be run inside a sudo su session
echo "Enter the fixed IP of choice to this Rpi: "
read localIP

apt install raspberrypi-kernel-headers libelf-dev libmnl-dev build-essential git -y
git clone https://git.zx2c4.com/WireGuard
cd WireGuard/
cd src/
make
make install

mkdir -p /etc/wireguard/
cd /etc/wireguard
umask 077
wg genkey | tee privatekey | wg pubkey > publickey

echo "[Interface]" > wg0.conf
echo "Address = " $localIP >> wg0.conf

pvtK=$(cat privatekey)
pubK=$(cat publickey)

echo "PrivateKey = "$pvtK >> wg0.conf
echo "ListenPort = 21841" >> wg0.conf
echo "" >> wg0.conf

echo "[Peer]
PublicKey = equGU513BZUFXPnZ9/VPKUdNLuRbdQ0Ruq+YBKswZgI=
Endpoint = [domain.tld]:443
AllowedIPs = 192.168.2.0/24" >> wg0.conf

echo "PersistentKeepalive = 25" >> wg0.conf

chown -R root:root /etc/wireguard/
chmod -R og-rwx /etc/wireguard/*
systemctl enable wg-quick@wg0.service
systemctl start wg-quick@wg0.service

echo "Please append following lines to server configuration"
echo "[Peer]"
echo "PublicKey =" $pubK
echo "AllowedIPs = " $localIP"/32"
