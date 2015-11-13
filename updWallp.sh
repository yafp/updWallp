#!/bin/bash
#
#  Name:       updWallp
#  Version:    0.1
#  Function:   Script to pick a random image from a folder, generate a dimmed & blured version of it and set it as wallpaper
#  Usage:      ./updWallp /path/to/yourImageSourceFolder
#  Github:     https://github.com/yafp/updWallp
#
#
#  Related:
#              - https://github.com/romannurik/muzei/
#              - https://github.com/aepirli/linmuzei



# ---------------------------------------------------------------------
# CONFIGURATION
# ---------------------------------------------------------------------
imageSourcePath=$1                                    #"/home/fpoeck/Dropbox/Photos/WallpaperTest/"
baseFile="currentBaseWallpaper.png"                   # path for copy of selected file
generatedFile="currentGeneratedWallpaper.png"         # filename for generated file
notifyPath="/usr/bin/notify-send"
bold=$(tput bold)
normal=$(tput sgr0)



# ---------------------------------------------------------------------
# CHECKREQUIREMENTS
# ---------------------------------------------------------------------
function checkRequirements() {
   echo "...Checking requirements"
   command -v convert >/dev/null 2>&1 || { echo >&2 "Imagemagick is required but not installed.  Aborting."; exit 1; }
}



# ---------------------------------------------------------------------
# CHECKIMAGESOURCEFOLDER
# ---------------------------------------------------------------------
function checkImageSourceFolder() {
   echo "...Checking image source folder: $imageSourcePath"

   if [ -d $imageSourcePath ];                     # if image source folder exists
   then
      echo "...Source folder exists"               # can continue
   else
      echo "ERROR: source folder doesnt exist"
      exit                                         # otherwise die
   fi
}



# ---------------------------------------------------------------------
# NOTIFICATION
# ---------------------------------------------------------------------
function displayNotification() {
   echo "$2"

   if [ -f $notifyPath ];    # if notify-send exists
   then
      notify-send "$1" "$2"
      #notify-send "Generated new wallpaper" -i "~/Desktop/logo.png"
   else
      echo "${bold}WARNING:${normal} notify-send not found"
   fi
}



# ---------------------------------------------------------------------
# GENERATE CURRENT IMAGES IN WORKING DIR
# ---------------------------------------------------------------------
generateNewWallpaper(){
   randomImage=$(find $imageSourcePath -type f | shuf -n 1)       # pick random image from source folder
   convert "$randomImage"  $baseFile                              # copy random base image to project folder

   # Create a dimmed & blur-verion of the image into the working dir
   #
   # dim - where -30 is to darken by 30 and +10 is to increase the contrast by 10.
   convert "$randomImage" -channel RGBA  -blur 0x8 -brightness-contrast -30x10  $generatedFile

   # displayNotification "updWallp" "Finished wallpaper generation"
}



# ---------------------------------------------------------------------
# SETLINUXWALLPAPER
# ---------------------------------------------------------------------
function setLinuxWallpaper() {
   echo "...Trying to set new wallpaper"
   echo "...This is a dummy"
   displayNotification "updWallp" "Set new wallpaper"
}



# #####################################################################
# SCRIPT-LOGIC
# #####################################################################
clear
echo "${bold}*** updWallp ***${normal}"
checkRequirements          # function to check the requirements
checkImageSourceFolder     # check if user-supplied source folder exists
generateNewWallpaper       # generates a new wallpaper
setLinuxWallpaper          # set the linux wallpaper
