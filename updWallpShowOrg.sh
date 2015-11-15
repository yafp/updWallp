#!/bin/bash
#
#  Name:       updWallpShowOrg
#  Function:   Script to pick a random image from a folder, generate a dimmed & blured version of it and set it as wallpaper
#  Usage:      ./updWallpShowOrg.sh
#  Github:     https://github.com/yafp/updWallp
#


# ---------------------------------------------------------------------
# INCLUDE MAIN CONFIG
# ---------------------------------------------------------------------
source config.sh
source functions.sh



# #####################################################################
# SCRIPT-LOGIC
# #####################################################################
clear
cd $updWallpDir

checkupdWallpFolder
setLinuxWallpaper "$backupFilename"        # set the linux wallpaper to the original file
sleep "$toggleTime"
setLinuxWallpaper "$outputFilename"        # set the linux wallpaper back to the dimmed/blured version
