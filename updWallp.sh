#!/bin/bash
#
#  Name:       updWallp
#  Version:    0.2
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
updWallpDir=$(pwd)                                    #
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
   printf "...Checking requirements:"
   command -v convert >/dev/null 2>&1 || { echo >&2 "Imagemagick is required but not installed.  Aborting."; exit 1; }
   printf "\t\t\t\t\t\t${bold}OK${normal}\n"
}



# ---------------------------------------------------------------------
# CHECKIMAGESOURCEFOLDER
# ---------------------------------------------------------------------
function checkImageSourceFolder() {
   if [ -d "$imageSourcePath" ];                                        # if image source folder exists
      then
      printf "...Source folder: $imageSourcePath \t\t${bold}OK${normal}\n"                 # can continue
   else
      printf "${bold}ERROR:${normal} source folder doesnt exist.\n"
      printf "${bold}...aborting now${normal}"
      exit                                                              # otherwise die
   fi
}



# ---------------------------------------------------------------------
# NOTIFICATION
# ---------------------------------------------------------------------
function displayNotification() {
   if [ -f $notifyPath ];    # if notify-send exists
   then
      notify-send "$1" "$2" -i "$updWallpDir/img/appIcon.png"
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
   printf "...Trying to activate the new wallpaper\n"

   if [ "$(pidof gnome-settings-daemon)" ]
     then
       printf "...Setting wallpaper using gsettings\t\t\t\t\t${bold}OK${normal}\n"
       gsettings set org.gnome.desktop.background picture-uri file://$updWallpDir/$outputFilename
     else
       if [ -f ~/.xinitrc ]
       then
         if [ "$(which feh)" ]
         then
           printf "Gnome-settings-daemons not running, setting wallpaper with feh..."
           feh $outputFilename
           feh_xinitSet
         elif [ "$(which hsetroot)" ]
         then
           printf "Gnome-settings-daemons not running, setting wallpaper with hsetroot..."
           hsetroot -cover $outputFilename
           hsetroot_xinitSet
         elif [ "$(which nitrogen)" ]
         then
           printf "Gnome-settings-daemons not running, setting wallpaper with nitrogen..."
           nitrogen $outputFilename
           nitrogen_xinitSet
         else
           printf "You need to have either feh, hsetroot or nitrogen, bruhbruh."
           exit
         fi
       else
         printf "You should have a ~/.xinitrc file."
         exit
       fi
     fi
}



# #####################################################################
# SCRIPT-LOGIC
# #####################################################################
clear
displayNotification "updWallp" "Started processing"
printf "${bold}*** updWallp ***${normal}\n\n"
printf "...Operating system: $OSTYPE\t\t\t\t\t\t${bold}OK${normal}\n"
checkRequirements          # function to check the requirements
printf "...WorkingDir: $updWallpDir\n"
checkImageSourceFolder     # check if user-supplied source folder exists
generateNewWallpaper       # generates a new wallpaper
setLinuxWallpaper          # set the linux wallpaper
