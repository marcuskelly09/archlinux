#!/bin/bash

# Functions
function get_drives {
	echo "Getting drives..."
	all_drives=()
	all_drives+=( $(lsblk -dno path) )
}

function check_user_input_validity () {
	func_output=""
	
	# $1 is the input, $2 is the length of the input array
	# Checks to see if input is within the indexes of the array
	if [[ $1 > 0 && $1 -le $2 ]]; then
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
		read -n 1 input

		# Checks if selected drive is valid
		check_user_input_validity $input ${#all_drives[@]}

		if [[ $func_output == "valid" ]]; then
			# Take user input -1 as the index for all_drives
			drive=${all_drives[$(($input - 1))]}
		else
			echo ""
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
echo "IMPORTANT: This script will $(tput bold)WIPE$(tput sgr0) your drive: ${drive} to install arch"
echo ""
echo "Press ENTER to continue, to abort press ctrl+c"
read input

exit

partition_drive

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
		echo "Please list the packages you would like to install seperated by spaces"
		read input
		pacstrap -K /mnt $input
	fi
fi

genfstab -U /mnt/etc/fstab

arch-chroot /mnt <<EOF

# Functions

function check_user_input_validity () {
	func_output=""
	
	# $1 is the input, $2 is the length of the input array
	# Checks to see if input is within the indexes of the array
	if [[ $1 > 0 && $1 -le $2 ]]; then
		func_output="valid"
		return 0
	else
		func_output="invalid"
		return 1
	fi
}

function get_base_timezones {
	alltimezones=()
	alltimezonesindexed=()
	count=0

	readarray -t allzones <<<$(timedatectl list-timezones --no-pager)
	
	# Removes repeated base time zones
	for zone in "${allzones[@]}"; do
		base="${zone%/*}"
		base_string_length=${#base}

		ispresent="false"
		for region in "${alltimezones[@]}"; do
			if [[ $base == $region ]]; then
				ispresent="true"	
			fi
		done
		
		if [[ $ispresent == "false" ]]; then
			alltimezones+=("$base")
		fi
	done

	# Adds indexes to base timezones
	for zone in "${alltimezones[@]}"; do
		((++count))
		alltimezonesindexed+=("[${count}] $zone")
	done
	
	# Lists all time zones in format [x] timezone in columns
	IFS=$'\n'
	column -c 120 <<< "${alltimezonesindexed[*]}"
}

loop="true"
page=("home")
while [[ $loop == "true" ]]; do
	# Checks if user it at home page
	if [[ "${page[-1]}" == "home" ]]; then
		clear
		echo "Please select you time zone, if the option you select has submenus, you can navigate them by selecting them"
		echo ""
		get_base_timezones
		echo ""
		echo "Please select a timezone"
		read input

		check_user_input_validity $input ${#alltimezones[@]}

		if [[ $func_output == "valid" ]]; then
			loop="false"
		fi
	fi
done

EOF

umount -R /mnt
