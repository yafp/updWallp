#!/bin/bash
#
#  Name:       updWallpShowOrg.sh
#  Function:   Script to temporary toggle back to the original image for a defined time
#  Usage:      ./updWallpShowOrg.sh
#  Github:     https://github.com/yafp/updWallp
#


# ---------------------------------------------------------------------
# LOCAL CONFIG
# ---------------------------------------------------------------------
updWallpDir="/home/fpoeck/Apps/updWallp"        # define the folder where you copied the updWallp folder to



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
