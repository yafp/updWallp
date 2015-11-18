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
updWallpDir=""              # define the folder where you copied the updWallp folder to
muzeiFilename="muzeiImage.png"
imageSourcePath=$1




# #####################################################################
# SCRIPT-LOGIC
# #####################################################################
if [ -d "$updWallpDir" ];
   then
   cd $updWallpDir

   source config.sh
   source functions.sh

   printf "${bold}${green}OK${normal} ... updWallp folder is set to: $updWallpDir\n"

   # Pre-Work (Checks)
   startUp
   checkOperatingSystem                         # check operating system
   checkImageMagick                             # function to check if ImageMagick is installed
   checkLocalOrRemoteMode                       # check if script runs in local or remote (muzei) mode

   # Core work
   generateNewWallpaper                         # generates a new wallpaper
   setLinuxWallpaper  "$outputFilename"         # set the linux wallpaper

   # Post work
   cleanupUpdWallpDir                           # Cleaning up
else
   printf "${bold}${red}ERROR:${normal} updWallp folder not configured or not valid. Aborting\n"
   exit                                                              # otherwise die
fi
