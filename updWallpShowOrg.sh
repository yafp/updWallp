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
updWallpDir=""        # define the folder where you copied the updWallp folder to



# #####################################################################
# SCRIPT-LOGIC
# #####################################################################
if [ -d "$updWallpDir" ];
   then
   clear
   cd $updWallpDir

   source config.sh
   source functions.sh

   printf "${bold}${green}OK${normal} ... updWallp folder is set to: $updWallpDir\n"

   startUp
   checkOperatingSystem                         # check operating system

   setLinuxWallpaper "$backupFilename"        # set the linux wallpaper to the original file
   sleep "$toggleTime"
   setLinuxWallpaper "$outputFilename"        # set the linux wallpaper back to the dimmed/blured version
else
   printf "${bold}${red}ERROR:${normal} updWallp folder not configured or not valid. Aborting\n"
   exit                                                              # otherwise die
fi
