# ArchInstall for Zephyrus G14 (Work In Progress)

**This script comes in three parts**

Part 1: My personal arch install script which creates a fresh linux installation with required packages for the G14 (Or really any recent ROG laptop)

Part 2: Sets up Hyprland as well as some packages in the hyprland ecosystem, Audio Services, and more

Part 3: My personal dotfiles which are my custom configurations, more explained in detail below

# Guide

Start off by following the Official setup guide and stop when you reach step 1.9 (Disk Partitioning)


Part 1:

1.1 Paste this command into your terminal
```
bash <(curl -fsSL https://raw.githubusercontent.com/marcuskelly09/archlinux/refs/heads/main/archinstall.sh)
```

1.2 Select your hostname and root password





--- 


Script part 1 does the following:

- Create an EFI partition and a BTRFS linux filesystem

- Create submodules using the reccomended setup from Arch

- Install all base packages that I use for my setup (See below)

- Generate fstab files

- Choose Language Variables

- Create the hostname

- Set a root password

**The following can be selected while using the script**

- Hostname

- Root Password

# Package List (My default)

```
pacstrap -K /mnt base linux-zen linux-firmware amd-ucode sof-firmware networkmanager nvim yay 
```
