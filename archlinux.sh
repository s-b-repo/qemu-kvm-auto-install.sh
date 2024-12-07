#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root."
  exit 1
fi

echo "Updating system packages..."
pacman -Syu --noconfirm

echo "Installing KVM, QEMU, libvirt, and other required packages..."
pacman -S --noconfirm qemu libvirt virt-manager virt-viewer dnsmasq iptables-nft ebtables bridge-utils

echo "Enabling and starting the libvirtd service..."
systemctl enable libvirtd
systemctl start libvirtd

echo "Checking for virtualization support..."
if grep -E -c '(vmx|svm)' /proc/cpuinfo > /dev/null; then
  echo "Virtualization is supported on your CPU."
else
  echo "Virtualization is not supported on your CPU. Exiting..."
  exit 1
fi

echo "Configuring libvirt to allow non-root user access..."
groupadd libvirt
usermod -aG libvirt $(logname)
usermod -aG kvm $(logname)

echo "Editing libvirt daemon configuration..."
sed -i 's/^#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/' /etc/libvirt/libvirtd.conf
sed -i 's/^#unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/' /etc/libvirt/libvirtd.conf

echo "Restarting libvirtd service to apply changes..."
systemctl restart libvirtd

echo "Installation and configuration complete."
echo "Please log out and log back in to apply user group changes."
