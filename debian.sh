#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root."
  exit 1
fi

echo "Updating system packages..."
sudo apt update && apt upgrade -y

echo "Installing KVM, QEMU, libvirt, and related tools..."
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager

echo "Enabling and starting the libvirtd service..."
sudo systemctl enable libvirtd
sudo systemctl start libvirtd

echo "Checking for virtualization support..."
if grep -E -c '(vmx|svm)' /proc/cpuinfo > /dev/null; then
  echo "Virtualization is supported on your CPU."
else
  echo "Virtualization is not supported on your CPU. Exiting..."
  exit 1
fi

echo "Configuring libvirt to allow non-root user access..."
sudo usermod -aG libvirt $(logname)
sudo usermod -aG kvm $(logname)

echo "Installation and configuration complete."
echo "Please log out and log back in to apply user group changes."

# Check if libvirtd socket is active
echo "Verifying libvirtd service..."
if systemctl is-active --quiet libvirtd; then
  echo "libvirtd is active and running."
else
  echo "libvirtd is not active. Please check the service status for troubleshooting."
fi
