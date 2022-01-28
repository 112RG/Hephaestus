#!/bin/sh

function banner()
{
  print "  ██╗  ██╗███████╗██████╗ ██╗  ██╗ █████╗ ███████╗███████╗████████╗██╗   ██╗███████╗    ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     ███████╗██████╗ "
  print "  ██║  ██║██╔════╝██╔══██╗██║  ██║██╔══██╗██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔════╝    ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ██╔════╝██╔══██╗"
  print "  ███████║█████╗  ██████╔╝███████║███████║█████╗  ███████╗   ██║   ██║   ██║███████╗    ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     █████╗  ██████╔╝"
  print "  ██╔══██║██╔══╝  ██╔═══╝ ██╔══██║██╔══██║██╔══╝  ╚════██║   ██║   ██║   ██║╚════██║    ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     ██╔══╝  ██╔══██╗"
  print "  ██║  ██║███████╗██║     ██║  ██║██║  ██║███████╗███████║   ██║   ╚██████╔╝███████║    ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗███████╗██║  ██║"
  print "  ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚══════╝    ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝"
  print "  Version 0.1"
}

function updateSysClock()
{
	print "Set system clock time"
	timedatectl set-ntp true
}

function initPackages()
{
	print "Init system on /mnt"
	pacstrap /mnt base linux linux-firmware
}

function genFStab()
{
	print "Generating fstab on /mnt"
	genfstab -U /mnt >> /mnt/etc/fstab
}

print () {
    echo -e "\e[1m\e[93m[ \e[92m•\e[93m ] \e[4m$1\e[0m"
}

# Setting up a password for the user account (function).
userpass_selector () {
while true; do
  read -r -s -p "Set a user password for $username: " userpass
	while [ -z "$userpass" ]; do
	echo
	print "You need to enter a password for $username."
	read -r -s -p "Set a user password for $username: " userpass
	[ -n "$userpass" ] && break
	done
  echo
  read -r -s -p "Insert password again: " userpass2
  echo
  [ "$userpass" = "$userpass2" ] && break
  echo "Passwords don't match, try again."
done
}

# Setting up a password for the root account (function).
rootpass_selector () {
while true; do
  read -r -s -p "Set a root password: " rootpass
	while [ -z "$rootpass" ]; do
	echo
	print "You need to enter a root password."
	read -r -s -p "Set a root password: " rootpass
	[ -n "$rootpass" ] && break
	done
  echo
  read -r -s -p "Password (again): " rootpass2
  echo
  [ "$rootpass" = "$rootpass2" ] && break
  echo "Passwords don't match, try again."
done
}

# Microcode detector (function).
microcode_detector () {
    CPU=$(grep vendor_id /proc/cpuinfo)
    if [[ $CPU == *"AuthenticAMD"* ]]; then
        print "An AMD CPU has been detected, the AMD microcode will be installed."
        microcode="amd-ucode"
    else
        print "An Intel CPU has been detected, the Intel microcode will be installed."
        microcode="intel-ucode"
    fi
}

# Setting up the hostname (function).
hostname_selector () {
    read -r -p "Please enter the hostname: " hostname
    if [ -z "$hostname" ]; then
        print "You need to enter a hostname in order to continue."
        hostname_selector
    fi
    echo "$hostname" > /mnt/etc/hostname
}

# Setting up the locale (function).
locale_set () {
    echo "$locale.UTF-8 UTF-8"  > /mnt/etc/locale.gen
    echo "LANG=$locale.UTF-8" > /mnt/etc/locale.conf
}

# Setting up the keyboard layout (function).
keyboard_set () {
    print "US keyboard layout will be used by default."
    kblayout="us"
    echo "KEYMAP=$kblayout" > /mnt/etc/vconsole.conf
}

# Selecting a kernel to install (function). 
kernel_selector () {
    print "List of kernels:"
    print "1) Stable: Vanilla Linux kernel with a few specific Arch Linux patches applied"
    print "2) Hardened: A security-focused Linux kernel"
    print "3) LTS: Long-term support (LTS) Linux kernel"
    print "4) Zen: A Linux kernel optimized for desktop usage"
    read -r -p "Insert the number of the corresponding kernel: " choice
    case $choice in
        1 ) kernel="linux"
            ;;
        2 ) kernel="linux-hardened"
            ;;
        3 ) kernel="linux-lts"
            ;;
        4 ) kernel="linux-zen"
            ;;
        * ) print "You did not enter a valid selection."
            kernel_selector
    esac
}

# Selecting a way to handle internet connection (function). 
network_selector () {
    print "Network utilities:"
    print "1) IWD: iNet wireless daemon is a wireless daemon for Linux written by Intel (WiFi-only)"
    print "2) NetworkManager: Universal network utility to automatically connect to networks (both WiFi and Ethernet)"
    print "3) wpa_supplicant: Cross-platform supplicant with support for WEP, WPA and WPA2 (WiFi-only, a DHCP client will be automatically installed as well)"
    print "4) dhcpcd: Basic DHCP client (Ethernet only or VMs)"
    print "5) I will do this on my own (only advanced users)"
    read -r -p "Insert the number of the corresponding networking utility: " choice
    case $choice in
        1 ) print "Installing IWD."
            pacstrap /mnt iwd >/dev/null
            print "Enabling IWD."
            systemctl enable iwd --root=/mnt &>/dev/null
            ;;
        2 ) print "Installing NetworkManager."
            pacstrap /mnt networkmanager >/dev/null
            print "Enabling NetworkManager."
            systemctl enable NetworkManager --root=/mnt &>/dev/null
            ;;
        3 ) print "Installing wpa_supplicant and dhcpcd."
            pacstrap /mnt wpa_supplicant dhcpcd >/dev/null
            print "Enabling wpa_supplicant and dhcpcd."
            systemctl enable wpa_supplicant --root=/mnt &>/dev/null
            systemctl enable dhcpcd --root=/mnt &>/dev/null
            ;;
        4 ) print "Installing dhcpcd."
            pacstrap /mnt dhcpcd >/dev/null
            print "Enabling dhcpcd."
            systemctl enable dhcpcd --root=/mnt &>/dev/null
            ;; 
        5 ) ;;
        * ) print "You did not enter a valid selection."
            network_selector
    esac
}

print "Weclome to the Hephaestus arch installer"
updateSysClock
PS3="Please select the disk where Arch Linux is going to be installed: "
select ENTRY in $(lsblk -dpnoNAME|grep -P "/dev/sd|nvme|vd");
do
    DISK=$ENTRY
    print "Installing Arch Linux on $DISK."
    break
done

# Deleting old partition scheme.
read -r -p "This will delete the current partition table on $DISK. Do you agree [y/N]? " response
response=${response,,}
if [[ "$response" =~ ^(yes|y)$ ]]; then
    print "Wiping $DISK."
    wipefs -af "$DISK" &>/dev/null
    sgdisk -Zo "$DISK" &>/dev/null
else
    print "Quitting."
    exit
fi

# Creating a new partition scheme.
print "Creating the partitions on $DISK."
parted -s "$DISK" \
    mklabel gpt \
    mkpart ESP fat32 1MiB 513MiB \
    set 1 esp on \
    mkpart ROOT 513MiB 100% \

ESP="/dev/disk/by-partlabel/ESP"
ROOT="/dev/disk/by-partlabel/ROOT"

# Informing the Kernel of the changes.
print "Informing the Kernel about the disk changes."
partprobe "$DISK"

# Formatting the ESP as FAT32.
print "Formatting the EFI Partition as FAT32."
mkfs.fat -F 32 $ESP &>/dev/null

# Formatting the ROOT as EXT4.
print "Formatting the ROOT Partition as EXT4."
mkfs.ext4 $ROOT &>/dev/null


mount $ROOT /mnt
mkdir /mnt/boot
mkdir /mnt/boot/efi
mount $ESP /mnt/boot/

# Enable parallel downloading in pacman
sed -i "s/^#ParallelDownloads.*$/ParallelDownloads = 10/" /etc/pacman.conf

reflector --country "Australia" --protocol https --latest 4 --save /etc/pacman.d/mirrorlist

kernel_selector

microcode_detector

network_selector

# Pacstrap (setting up a base sytem onto the new root).
print "Installing the base system (it may take a while)."
pacstrap /mnt --needed base $kernel $microcode linux-firmware $kernel-headers grub rsync efibootmgr reflector base-devel >/dev/null

# Setting up the hostname.
hostname_selector

# Generating /etc/fstab.
print "Generating a new fstab."
genfstab -U /mnt >> /mnt/etc/fstab

# Setting username.
read -r -p "Please enter name for a user account (enter empty to not create one): " username
userpass_selector
rootpass_selector

# Setting up the locale.
locale_set

# Setting up keyboard layout.
keyboard_set

# Setting hosts file.
print "Setting hosts file."
cat > /mnt/etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $hostname.localdomain   $hostname
EOF

# Configuring the system.    
arch-chroot /mnt /bin/bash -e <<EOF
    # Setting up timezone.
    echo "Setting up the timezone."
    ln -sf /usr/share/zoneinfo/$(curl -s http://ip-api.com/line?fields=timezone) /etc/localtime &>/dev/null
    
    # Setting up clock.
    echo "Setting up the system clock."
    hwclock --systohc
    
    # Generating locales.
    echo "Generating locales."
    locale-gen &>/dev/null
    
    # Generating a new initramfs.
    echo "Creating a new initramfs."
    mkinitcpio -P &>/dev/null
    
    # Installing GRUB.
    echo "Installing GRUB on /boot."
    grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi &>/dev/null
    # Creating grub config file.
    echo "Creating GRUB config file."
    grub-mkconfig -o /boot/grub/grub.cfg &>/dev/null
EOF

# Setting root password.
print "Setting root password."
echo "root:$rootpass" | arch-chroot /mnt chpasswd

# Setting user password.
if [ -n "$username" ]; then
    print "Adding the user $username to the system with root privilege."
    arch-chroot /mnt useradd -m -G wheel -s /bin/bash "$username"
    sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /mnt/etc/sudoers
    print "Setting user password for $username." 
    echo "$username:$userpass" | arch-chroot /mnt chpasswd
fi

# Pacman eye-candy features.
print "Enabling colours, animations, and parallel in pacman."
sed -i 's/#Color/Color\nILoveCandy/;s/^#ParallelDownloads.*$/ParallelDownloads = 10/' /mnt/etc/pacman.conf

print "Setup script complete please run. The post install script"
#arch-chroot /mnt pacman -S pipewire pipewire-pulse firefox git --noconfirm --needed




