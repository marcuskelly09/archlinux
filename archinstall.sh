#!/bin/bash

# Functions
function get_drives {
	echo "Getting drives..."
	all_drives=()
	all_drives+=( $(lsblk -dno path) )
}

function check_drive_validity () {
	func_output=""
	array_length=${#all_drives[@]}

	# Checks to see if input is within the indexes of the array
	if [[ $1 > 0 && $1 -le $array_length ]]; then
		func_output="valid"
		return 0
	else
		func_output="invalid"
		return 1
	fi
}

function custom_drive_selection {
	if [[ $input == "y" || $input == "" ]]; then
		drive="/dev/nvme0n1"
	else
		# Custom drive selection
		clear
		get_drives
		
		# Lists all drives in format [x] /dev/sda
		count=0
		for temp_drive in "${all_drives[@]}"; do
			((++count))
			echo "[${count}] ${temp_drive}"
		done

		# User selection sreen
		echo "Please select your drive:"
		read input

		# Checks if selected drive is valid
		check_drive_validity $input

		if [[ $func_output == "valid" ]]; then
			# Take user input -1 as the index for all_drives
			drive=${all_drives[$(($input - 1))]}
		else
			echo "ERROR: drive is invalid, aborting"
			exit
		fi
	fi
}

function partition_drive {
	wipefs -a $drive
	parted -s $drive mklabel gpt
	parted -s $drive mkpart primary fat32 1Mib 3Gib
	parted -s $drive mkpart primary btrfs 3Gib 100%
	parted -s ${drive}p1 set 1 esp on

	mkfs.fat -F32 ${drive}p1
	mkfs.btrfs -f ${drive}p2

	mount ${drive}p2 /mnt

	btrfs subvolume create /mnt/@
	btrfs subvolume create /mnt/@home
	btrfs subvolume create /mnt/@var

	umount /mnt

	mount -o subvol=@ ${drive}p2 /mnt

	mkdir /mnt/{boot,home,var}
	mkdir /mnt/boot/efi

	mount ${drive}p1 /mnt/boot/efi

	mount -o subvol=@home ${drive}p2 /mnt/home
	mount -o subvol=@var ${drive}p2 /mnt/var

	echo "Volumes successfully mounted"
}

# Script Starts
clear
echo "Welcome to Asus Arch Install"
echo ""
echo "On any (y/n) sequence, ENTER will default to y"
echo ""

echo "Would you to install with default options? (y/n)"
read input

# Default installation prompt
if [[ $input == "Y" || $input == "y" || $input == "" ]]; then
	options="default"
	echo "DEBUG: using default options"
else
	options="custom"
fi

clear
echo "Custom Installation"
echo
# Drive selection prompt
if [[ $options == "default" ]]; then
	drive="/dev/nvme0n1"
else
	echo "Would you like to install Arch onto the default drive: /dev/nvme0n1? (y/n)"
	read input

	# Custom installation selection
	if [[ $input == "Y" || $input == "y" || $input == "" ]]; then
		drive="/dev/nvme0n1"
	else
		custom_drive_selection
	fi
fi


clear
echo "IMPORTANT: This script will WIPE your drive: ${drive} to install arch"
echo ""
echo "Press ENTER to continue, to abort press ctrl+c"
read input

### Destructive

### partition_drive

if [[ $options == "default" ]]; then
	pacstrap -K /mnt base linux-zen linux-zen-headers linux-firmware sof-firmware refind gdisk networkmanager sudo base-devel fastfetch
else
	echo "Would you like to install the default packages listed below? (y/n)"
	echo ""
	echo "base linux-zen linux-zen-headers linux-firmware sof-firmware refind gdisk networkmanager sudo base-devel fastfetch"
	read input

	if [[ $input == "Y" || $input == "y" || $input == "" ]]; then
		pacstrap -K /mnt base linux-zen linux-zen-headers linux-firmware sof-firmware refind gdisk networkmanager sudo base-devel fastfetch
	else
		echo "Please list the packages you would like to install seperated by space"
		read input
		pacstrap -K /mnt $input
	fi
fi
