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
    print "Setting System local"
    echo "en_US.UTF-8 UTF-8"  > /mnt/etc/locale.gen
    echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf
}

# Setting up the keyboard layout (function).
keyboard_set () {
    print "US keyboard layout will be used by default."
    kblayout="us"
    echo "KEYMAP=$kblayout" > /mnt/etc/vconsole.conf
}


# Selecting a way to handle internet connection (function). 
network_set () {
    pacstrap /mnt networkmanager >/dev/null
    print "Enabling NetworkManager."
    systemctl enable NetworkManager --root=/mnt &>/dev/null
}

setup_disk () {
    PS3="Please select the disk where Arch Linux is going to be installed: "
    select ENTRY in $(lsblk -dpnoNAME|grep -P "/dev/sd|nvme|vd");
    do
        DISK=$ENTRY
        print "Installing Arch Linux on $DISK."
        break
    done

    # disk prep
    sgdisk -Z ${DISK} # zap all on disk
    sgdisk -a 2048 -o ${DISK} # new gpt disk 2048 alignment

    # create partitions
    sgdisk -n 1:0:+1000M ${DISK} # partition 1 (UEFI SYS), default start block, 512MB
    sgdisk -n 2:0:0     ${DISK} # partition 2 (Root), default start, remaining

    # set partition types
    sgdisk -t 1:ef00 ${DISK}
    sgdisk -t 2:8300 ${DISK}

    # label partitions
    sgdisk -c 1:"UEFISYS" ${DISK}
    sgdisk -c 2:"ROOT" ${DISK}

    # make filesystems
    echo -e "\nCreating Filesystems...\n$HR"

    mkfs.vfat -F32 -n "UEFISYS" "${DISK}p1"
    mkfs.ext4 -L "ROOT" "${DISK}p2"

    # mount target
    mkdir /mnt
    mount -t ext4 "${DISK}p2" /mnt
    mkdir /mnt/boot
    mkdir /mnt/boot/efi
    mount -t vfat "${DISK}p1" /mnt/boot/
}
print "Weclome to the Hephaestus arch installer"
updateSysClock
setup_disk
# # Deleting old partition scheme.
# read -r -p "This will delete the current partition table on $DISK. Do you agree [y/N]? " response
# response=${response,,}
# if [[ "$response" =~ ^(yes|y)$ ]]; then
#     print "Wiping $DISK."
#     wipefs -af "$DISK"
#     sgdisk -Zo "$DISK"
# else
#     print "Quitting."
#     exit
# fi

# # Creating a new partition scheme.
# print "Creating the partitions on $DISK."
# parted -s "$DISK" \
#     mklabel gpt \
#     mkpart ESP fat32 1MiB 513MiB \
#     set 1 esp on \
#     mkpart ROOT 513MiB 100% \

# ESP="/dev/disk/by-partlabel/ESP"
# ROOT="/dev/disk/by-partlabel/ROOT"

# # Informing the Kernel of the changes.
# print "Informing the Kernel about the disk changes."
# partprobe "$DISK"

# # Formatting the ESP as FAT32.
# print "Formatting the EFI Partition as FAT32."
# mkfs.fat -F 32 $ESP &>/dev/null

# # Formatting the ROOT as EXT4.
# print "Formatting the ROOT Partition as EXT4."
# mkfs.ext4 $ROOT &>/dev/null

# Enable parallel downloading in pacman
sed -i "s/^#ParallelDownloads.*$/ParallelDownloads = 10/" /etc/pacman.conf

reflector --country "Australia" --protocol https --latest 4 --save /etc/pacman.d/mirrorlist

# Set microcode
microcode_detector

# Set network stack
network_set

# Pacstrap (setting up a base sytem onto the new root).
print "Installing the base system (it may take a while)."
pacstrap /mnt --needed base linux $microcode linux-firmware linux-headers grub rsync efibootmgr reflector base-devel

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

mount $ESP /mnt/boot

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
    locale-gen
    
    # Generating a new initramfs.
    echo "Creating a new initramfs."
    mkinitcpio -P
    
    # Installing GRUB.
    echo "Installing GRUB on /boot."
    mkdir /boot/efi
    grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
    # Creating grub config file.
    echo "Creating GRUB config file."
    grub-mkconfig -o /boot/grub/grub.cfg
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




