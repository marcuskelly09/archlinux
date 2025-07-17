# This is a note of commands i run to setup arch (barebones for G14)
umount -a
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
pacstap -K /mmt base linux-zen linux-firmware sof-firmware amd-ucode networkmanager nano vim man-db man-pages reflector sudo
