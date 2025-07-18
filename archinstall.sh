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

# Script Starts
clear
echo "Welcome to Asus Arch Install"
echo ""
echo "Would you like to install Arch onto the default drive: /dev/nvme0n1? (y/n)"
read input

# Custom options Selection
if [[ $input == "y" || $input == "" ]]; then
	drive="/dev/nvme0n1"
else
	# Custom drive selection
	clear
	get_drives

	count=0
	for temp_drive in "${all_drives[@]}"; do
		((++count))
		echo "[${count}] ${temp_drive}"
	done
	echo "Please select your drive:"
	read input

	# Checks if drive is valid
	check_drive_validity $input

	if [[ $func_output == "valid" ]]; then
		drive=${all_drives[$(($input - 1))]}
	else
		echo "ERROR: drive is invalid, aborting"
		exit
	fi
fi

echo "Using drive: ${drive}"
