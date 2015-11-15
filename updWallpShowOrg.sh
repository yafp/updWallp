#!/bin/bash
#
#  Name:       updWallpShowOrg
#  Function:   Script to pick a random image from a folder, generate a dimmed & blured version of it and set it as wallpaper
#  Usage:      ./updWallpShowOrg.sh
#  Github:     https://github.com/yafp/updWallp
#


# ---------------------------------------------------------------------
# LOCAL CONFIG
# ---------------------------------------------------------------------
updWallpDir=""        # define the folder where you copied the updWallp folder to



# #####################################################################
# SCRIPT-LOGIC
# #####################################################################
clear
cd $updWallpDir

source config.sh
source functions.sh

checkupdWallpFolder
setLinuxWallpaper "$backupFilename"        # set the linux wallpaper to the original file
sleep "$toggleTime"
setLinuxWallpaper "$outputFilename"        # set the linux wallpaper back to the dimmed/blured version
