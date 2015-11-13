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
updWallpDir=""                                          # Define where the updWallp folder is located- Must be configured

imageSourcePath=$1                                    # example: "/home/foo/Pictures"
backupFilename="currentBaseWallpaper.png"             # filename for backup copy of selected file
outputFilename="currentGeneratedWallpaper.png"        # filename for generated file

blurCommand="-channel RGBA  -blur 0x9"                # imageMagick blur command example:    -channel RGBA  -blur 0x8
dimCommand="-brightness-contrast -30x10"              # imageMagick dim command example:     -brightness-contrast -30x10
                                                      #   where -30 is to darken by 30 and +10 is to increase the contrast by 10.
notifyPath="/usr/bin/notify-send"
bold=$(tput bold)                                     # cli output in bold
normal=$(tput sgr0)                                   # cli output in normal



# ---------------------------------------------------------------------
# CHECKIMAGEMAGICK
# ---------------------------------------------------------------------
function checkImageMagick() {
   printf "...Checking for ImageMagick:"
   command -v convert >/dev/null 2>&1 || { echo >&2 "Imagemagick is required but not installed.  Aborting."; exit 1; }
   printf "\t\t\t\t\t\t\t\t\t${bold}OK${normal}\n"
}


# ---------------------------------------------------------------------
# CHECKUPDWALLP
# ---------------------------------------------------------------------
function checkupdWallpFolder() {
   printf "...Checking updWallp working dir\n"
   if [ -d "$updWallpDir" ];                                                    # if script folder is defined
      then
      printf "...updWallp folder:\t\t$updWallpDir \t\t${bold}OK${normal}\n"      # can continue
   else
      displayNotification "updWallp" "updWallp folder not configured"
      printf "${bold}ERROR:${normal} updWallp folder not configured\n"
      printf "${bold}...aborting now${normal}"
      exit                                                              # otherwise die
   fi
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
# NOTIFICATION
# ---------------------------------------------------------------------
function displayNotification() {
   if [ -f $notifyPath ];    # if notify-send exists
   then
      notify-send "$1" "$2" -i "$updWallpDir/img/appIcon_128px.png"
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
       printf "...Setting wallpaper using gsettings\t\t\t\t\t\t\t\t${bold}OK${normal}\n"
       gsettings set org.gnome.desktop.background picture-uri file://$updWallpDir/$outputFilename
       displayNotification "updWallp" "Enjoy your new wallpaper"
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
printf "${bold}*** updWallp ***${normal}\n\n"
printf "...Operating system:\t\t $OSTYPE\t\t\t\t\t\t\t${bold}OK${normal}\n"

checkImageMagick           # function to check if ImageMagick is installed
checkupdWallpFolder        # function to check if user configured the script folder
checkImageSourceFolder     # check if user-supplied source folder exists

generateNewWallpaper       # generates a new wallpaper
setLinuxWallpaper          # set the linux wallpaper
