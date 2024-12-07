Make it executable:

chmod +x scriptname.sh
Run the script as root:

    sudo ./scriptname.sh
    sudo bash scriptname.sh

Post-Installation Steps

    Log out and log back in for group changes to take effect.
    Verify the installation by running:

virsh list --all

If this works without errors, the setup is complete.
Launch virt-manager for a graphical interface to manage virtual machines.
