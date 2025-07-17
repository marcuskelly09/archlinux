# This is a note of commands i run to setup arch (barebones for G14)
wipefs -a /dev/nvme0n1
parted -s /dev/nvme0n1 mklabel gpt
parted -s /dev/nvme0n1 mkpart primary fat32 1Mib 3Gib
parted -s /dev/nvme0n1 set 1 esp on
parted -s /dev/nvme0n1 mkpart primary btrfs 3Gib 100%
mkfs.fat -F32 /dev/nvme0n1p1
mkfs.btrfs -f /dev/nvme0n1p2
mount /dev/nvme0n1p2 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@var
umount /mnt
mount -o subvol=@ /dev/nvme0n1p2 /mnt
mkdir /mnt/{boot,home,var}
mkdir /mnt/boot/efi
mount /dev/nvme0n1p1 /mnt/boot/efi
mount -o subvol=@home /dev/nvme0n1p2 /mnt/home
mount -o subvol=@var /dev/nvme0n1p2 /mnt/var
pacstrap -K /mnt base linux-zen linux-zen-headers linux-firmware sof-firmware refind gdisk networkmanager nano nvim man-db man-pages reflector sudo
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt <<EOF
    ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
    hwclock --systohc
    locale-gen
    echo "LANG=en_US.UTF-8" > /etc/locale.conf
    echo "laptoparch" > /etc/hostname
    refind-install
    partuuid=$(blkid -s UUID -o value /dev/nvme0n1p2)
    echo "partuuid=$partuuid"
EOF

echo "run umount -R /mnt when done"

echo "Installation complete, set a root password and install a bootloader"