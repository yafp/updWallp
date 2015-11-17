#!/bin/bash
#
#  Name:       updWallp.sh
#  Function:   Script to pick a random image from a folder, generate a dimmed & blured version of it and set it as wallpaper
#  Usage:      
#					local mode: 			./updWallp.sh /path/to/yourImageSourceFolder
#					remote mode: 			./updWallp.sh
#  Github:     https://github.com/yafp/updWallp
#


# ---------------------------------------------------------------------
# LOCAL CONFIG
# ---------------------------------------------------------------------
updWallpDir="/home/fpoeck/Apps/updWallp"              # define the folder where you copied the updWallp folder to
muzeiFilename="muzeiImage.png"
imageSourcePath=$1



# #####################################################################
# SCRIPT-LOGIC
# #####################################################################
clear
cd $updWallpDir

source config.sh
source functions.sh

printf "${bold}*** updWallp (Version: $appVersion) ***${normal}\n\n"

# Pre-Work (Checks)
checkOperatingSystem                         # check operating system
checkImageMagick                             # function to check if ImageMagick is installed
checkupdWallpFolder                          # function to check if user configured the script folder
checkLocalOrRemoteMode                       # check if script runs in local or remote (muzei) mode

# Core work
generateNewWallpaper                         # generates a new wallpaper
setLinuxWallpaper  "$outputFilename"         # set the linux wallpaper

# Post work
cleanupUpdWallpDir                           # Cleaning up
