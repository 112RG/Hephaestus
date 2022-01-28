PS3="Please select the disk where Arch Linux is going to be installed: "
select ENTRY in $(lsblk -dpnoNAME|grep -P "/dev/sd|nvme|vd");
do
    DISK=$ENTRY
    echo "Installing Arch Linux on $DISK."
    break
done
EFI_PARTITION="${DISK}1"
ROOT_PARTITION="${DISK}2"
# disk prep
sgdisk -Z ${DISK} # zap all on disk
sgdisk -a 2048 -o ${DISK} # new gpt disk 2048 alignment
# create partitions
sgdisk -n 1:0:+1000M ${DISK} # partition 1 (UEFI SYS), default start block, 512MB
sgdisk -n 2:0:0     ${DISK} # partition 2 (Root), default start, remaining
# set partition types
sgdisk -t 1:ef00 ${DISK}
sgdisk -t 2:8300 ${DISK}

# make filesystems
echo -e "\nCreating Filesystems...\n$HR"
mkfs.fat -F32 ${EFI_PARTITION}
mkfs.ext4 ${ROOT_PARTITION}
# mount target
mkdir /mnt
mount "${ROOT_PARTITION}" /mnt
mkdir /mnt/boot
mkdir /mnt/boot/efi
mount "${EFI_PARTITION}" /mnt/boot/