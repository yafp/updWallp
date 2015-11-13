#!/bin/bash
#
#  Name:       updWallp
#  Version:    0.1
#  Function:   Script to pick a random image from a folder, generate a dimmed & blured version of it and set it as wallpaper
#  Usage:      ./updWallp.sh /path/to/yourImageSourceFolder
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
backupFilename="currentBaseWallpaper.png"             # path for copy of selected file
outputFilename="currentGeneratedWallpaper.png"        # filename for generated file
updWallpDir=""                                        #
blurCommand="-channel RGBA  -blur 0x8"                # imageMagick blur command example:    -channel RGBA  -blur 0x8
dimCommand="-brightness-contrast -30x10"              # imageMagick dim command example:     -brightness-contrast -30x10
                                                      #   where -30 is to darken by 30 and +10 is to increase the contrast by 10.
notifyPath="/usr/bin/notify-send"
bold=$(tput bold)                                     # cli output in bold
normal=$(tput sgr0)                                   # cli output in normal



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
   if [ -d "$imageSourcePath" ];                                        # if image source folder exists
      then
      echo "...Source folder '$imageSourcePath' exists"                 # can continue
   else
      echo "${bold}ERROR:${normal} source folder doesnt exist.die"
      echo "${bold}...aborting now${normal}"
      exit                                                              # otherwise die
   fi
}



# ---------------------------------------------------------------------
# NOTIFICATION
# ---------------------------------------------------------------------
function displayNotification() {
   if [ -f $notifyPath ];    # if notify-send exists
   then
      notify-send "$1" "$2"
      #notify-send "Generated new wallpaper" -i "~/Desktop/logo.png"
   else
      printf "${bold}WARNING:${normal} notify-send not found\n"
   fi
}



# ---------------------------------------------------------------------
# GENERATE CURRENT IMAGES IN WORKING DIR
# ---------------------------------------------------------------------
generateNewWallpaper(){
   randomImage=$(find $imageSourcePath -type f | shuf -n 1)             # pick random image from source folder
   convert "$randomImage" $backupFilename                              # copy random base image to project folder
   convert "$randomImage" $blurCommand $dimCommand  $outputFilename     # Create a dimmed & blur-verion of the image into the working dir
}



# ---------------------------------------------------------------------
# SETLINUXWALLPAPER
# ---------------------------------------------------------------------
function setLinuxWallpaper() {
   printf "...Trying to set new wallpaper\n"
   printf "...This is a dummy\n"
   displayNotification "updWallp" "Set new wallpaper"
   printf "\n${bold}Finished${normal}\n"
}



# #####################################################################
# SCRIPT-LOGIC
# #####################################################################
clear
printf "${bold}*** updWallp ***${normal}\n\n"
checkRequirements          # function to check the requirements
checkImageSourceFolder     # check if user-supplied source folder exists
generateNewWallpaper       # generates a new wallpaper
setLinuxWallpaper          # set the linux wallpaper
