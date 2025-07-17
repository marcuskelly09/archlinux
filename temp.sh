# This is a note of commands i run to setup arch (barebones for G14)
wipefs -a /dev/nvme0n1
parted -s /dev/nvme0n1 mklabel gpt
parted -s /dev/nvme0n1 mkpart primary fat32 1Mib 3Gib
parted -s /dev/nvme0n1 set 1 esp on
parted -s /dev/nvme0n1 mkpart primary btrfs 3Gib 100%
mkfs.fat /F32 /dev/nvme0n1p1
mkfs.btrfs -f /dev/nvme0n1p2
mount /dev/nvme0n1p2 /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@var
umount /mnt
pacstrap -K /mmt base linux-zen linux-firmware sof-firmware amd-ucode networkmanager nano vim man-db man-pages reflector sudo
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc
locale-gen
nvim /etc/locale.conf
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "laptoparch" > /etc/hostname