#!/bin/bash
# network-info.sh
# Išsami tinklo informacija Linux sistemai

echo "==== Tinklo adapteriai ir IP adresai ===="
ip addr show

echo -e "\n==== Tinklo sąsajos ===="
ip link show

echo -e "\n==== Maršrutizacijos lentelė ===="
ip route show

echo -e "\n==== DNS serveriai ===="
cat /etc/resolv.conf

echo -e "\n==== ARP lentelė ===="
ip neigh show

echo -e "\n==== Aktyvūs ryšiai (netstat) ===="
netstat -tunap

echo -e "\n==== Hostname ir /etc/hosts ===="
echo "Hostname: $(hostname)"
cat /etc/hosts

echo -e "\n==== NetworkManager statusas ===="
nmcli device status 2>/dev/null || echo "NetworkManager neįdiegtas"

echo -e "\n==== DHCP informacija (jei yra) ===="
sudo dhclient -v -n 2>/dev/null || echo "dhclient neįdiegtas arba nėra DHCP"

echo -e "\n==== Viešas IP adresas ===="
curl -s https://ipinfo.io/ip || wget -qO- https://ipinfo.io/ip

echo -e "\n==== Pabaiga ===="