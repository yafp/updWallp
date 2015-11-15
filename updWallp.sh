#!/bin/bash
#
#  Name:       updWallp
#  Version:    0.3
#  Function:   Script to pick a random image from a folder, generate a dimmed & blured version of it and set it as wallpaper
#  Usage:      ./updWallp.sh /path/to/yourImageSourceFolder
#  Github:     https://github.com/yafp/updWallp
#


# ---------------------------------------------------------------------
# INCLUDE MAIN CONFIG
# ---------------------------------------------------------------------
source config.sh
source functions.sh

imageSourcePath=$1                                    # example: "/home/foo/Pictures"


# ---------------------------------------------------------------------
# CHECKIMAGEMAGICK
# ---------------------------------------------------------------------
function checkImageMagick() {
   printf "...Checking for ImageMagick:"
   command -v convert >/dev/null 2>&1 || { echo >&2 "Imagemagick is required but not installed.  Aborting."; exit 1; }
   printf "\t\t\t\t\t\t\t\t\t${bold}OK${normal}\n"
}



# ---------------------------------------------------------------------
# CHECKIMAGESOURCEFOLDER
# ---------------------------------------------------------------------
function checkImageSourceFolder() {
   if [ -d "$imageSourcePath" ];                                        # if image source folder exists
      then
      printf "...Source folder:\t\t$imageSourcePath \t${bold}OK${normal}\n"                 # can continue
   else
      displayNotification "updWallp" "Source folder missing"
      printf "${bold}ERROR:${normal} source folder doesnt exist.\n"
      printf "${bold}...aborting now${normal}"
      exit                                                              # otherwise die
   fi
}




# ---------------------------------------------------------------------
# GENERATE CURRENT IMAGES IN WORKING DIR
# ---------------------------------------------------------------------
generateNewWallpaper(){
   randomImage=$(find $imageSourcePath -type f | shuf -n 1)             # pick random image from source folder
   convert "$randomImage" $backupFilename                               # copy random base image to project folder
   convert "$randomImage" $blurCommand $dimCommand  $outputFilename     # Create a dimmed & blur-verion of the image into the working dir
}



# #####################################################################
# SCRIPT-LOGIC
# #####################################################################
clear
cd $updWallpDir

printf "${bold}*** updWallp ***${normal}\n\n"
printf "...Operating system:\t\t $OSTYPE\t\t\t\t\t\t\t${bold}OK${normal}\n"

checkImageMagick                             # function to check if ImageMagick is installed
checkupdWallpFolder                          # function to check if user configured the script folder
checkImageSourceFolder                       # check if user-supplied source folder exists

generateNewWallpaper                         # generates a new wallpaper
setLinuxWallpaper  "$outputFilename"         # set the linux wallpaper
