#!/bin/bash
#
#  Name:       updWallp
#  Function:   Script to pick a random image from a folder, generate a dimmed & blured version of it and set it as wallpaper
#  Usage:      ./updWallp.sh /path/to/yourImageSourceFolder
#  Github:     https://github.com/yafp/updWallp
#


# ---------------------------------------------------------------------
# LOCAL CONFIG
# ---------------------------------------------------------------------
updWallpDir="/home/fidel/Apps/updWallp"              # define the folder where you copied the updWallp folder to
muzeiFilename="muzeiImage.png"
imageSourcePath=$1




# ---------------------------------------------------------------------
# Checking the operating system
# ---------------------------------------------------------------------
function checkOperatingSystem()
{
   if [[ $OSTYPE = *linux* ]]
      then
         printf "${bold}OK${normal} ... Operating system: $OSTYPE\n"
   else
         printf "${bold}ERROR${normal} ... Unexpected operating system: $OSTYPE Aborting\n"
         exit
   fi

}



# ---------------------------------------------------------------------
# Check if imagemagick is installed
# ---------------------------------------------------------------------
function checkImageMagick() {
   if [ "$(which convert)" ]
   then
      printf "${bold}OK${normal} ... Found ImageMagick\n"
   else
      printf "${bold}ERROR${normal} ... ImageMagick not found\n"
      exit
   fi
}



# ---------------------------------------------------------------------
# Check if the user wants to use updWallp in local or remote mode
# - local: use images from a local image folder
# - remote: use the art-picture of the current day delivered by muzei (muzei-mode)
# ---------------------------------------------------------------------
function checkLocalOrRemoteMode()
{
   if [ -z "$imageSourcePath" ]; then
      printf "${bold}OK${normal} ... Remote Mode (Muzei Mode)\n"
      checkRemoteRequirements
      getRemoteMuzeiImage
   else
      printf "${bold}OK${normal} ... Local Mode\n"
      printf "${bold}OK${normal} ... Submitted image path: "$imageSourcePath"\n"
      checkImageSourceFolder
   fi
}



# ---------------------------------------------------------------------
# check if the path to the local image folder is valid
# Exit if the user submits a non-valid path
# ---------------------------------------------------------------------
function checkImageSourceFolder() {
   if [ -d "$imageSourcePath" ];                                                 # if image source folder exists
      then
      printf "${bold}OK${normal} ... Source folder: $imageSourcePath is valid\n"      # can continue
      getNewRandomLocalFilePath                                                  # get a new local filepath
   else
      printf "${bold}ERROR${normal} ... Local mode but image dir isnt a valid directory. Aborting\n"      # can continue
      exit
   fi
}



# ---------------------------------------------------------------------
# GETREMOTEMUZEIIMAGE
# ---------------------------------------------------------------------
function getRemoteMuzeiImage()
{
   if ! [ -f ./muzeich.json ]
      then
      curl -o muzeich.json 'https://muzeiapi.appspot.com/featured?cachebust=1'
   else
      curl -o muzeich2.json 'https://muzeiapi.appspot.com/featured?cachebust=1'
      if [ "$(cmp muzeich.json muzeich2.json)" ]
         then
         mv muzeich2.json muzeich.json
         printf "${bold}OK${normal} ... There is a new Muzei image available. Loading it.\n"
      else
         rm muzeich2.json
         printf "${bold}OK${normal} ... There is no new Muzei image available. Nothing to do here.\n"
         #exit
      fi
   fi


   # parse the Muzei JSON
   imageUri=`jq '.imageUri' $updWallpDir/muzeich.json | sed s/\"//g`
   imageFile=`basename $imageUri`
   title=`jq '.title' $updWallpDir/muzeich.json | sed s/\"//g`
   byline=`jq '.byline' $updWallpDir/muzeich.json | sed s/\"//g`

   echo "File $imageFile does not exist, downloading..."
   curl -O $imageUri
   convert $imageFile $muzeiFilename

   newImage=$updWallpDir/$muzeiFilename

   printf "${bold}OK${normal} ... Finished getting latest Muzei image.\n"
}





# ---------------------------------------------------------------------
# SELECT A RANDOM LOCAL FILE FROM USER SUPPLIED PATH
# ---------------------------------------------------------------------
function getNewRandomLocalFilePath()
{
   newImage=$(find $imageSourcePath -type f | shuf -n 1)             # pick random image from source folder
   printf "${bold}OK${normal} ... Selected a new random image from local folder\n"
}



# ---------------------------------------------------------------------
# GENERATE CURRENT IMAGES IN WORKING DIR
# ---------------------------------------------------------------------
function generateNewWallpaper()
{
   convert "$newImage" $backupFilename                               # copy random base image to project folder
   convert "$newImage" $blurCommand $dimCommand  $outputFilename     # Create a dimmed & blur-verion of the image into the working dir
   printf "${bold}OK${normal} ... Generated the new Wallpaper in $updWallpDir\n"
}



# ---------------------------------------------------------------------
# Check the package requirements for remote mode (aka muzei mode)
# - cURL
# - jq
# ---------------------------------------------------------------------
function checkRemoteRequirements()
{
   # check for curl
   if [ "$(which curl)" ]
   then
      printf "${bold}OK${normal} ... Found cURL (Muzei-Mode)\n"
   else
      printf "${bold}ERROR${normal} ... cURL not found (Muzei-Mode). Aborting\n"
      exit
   fi

   # check for jq
   if [ "$(which jq)" ]
   then
      printf "${bold}OK${normal} ... Found JQ (Muzei-Mode)\n"
   else
      printf "${bold}ERROR${normal} ... JQ not found (Muzei-Mode). Aborting\n"
      exit
   fi
}



# ---------------------------------------------------------------------
# Clean the app folder at the end of the processing
# ---------------------------------------------------------------------
function cleanupUpdWallpDir()
{
   if [ -f "$imageFile" ]
      then
      rm $imageFile
   fi

   if [ -f "$muzeiFilename" ]
      then
      rm $muzeiFilename
   fi
   printf "${bold}OK${normal} ... Finished cleaning up $updWallpDir\n"
}




# #####################################################################
# SCRIPT-LOGIC
# #####################################################################
clear
cd $updWallpDir

source config.sh
source functions.sh

printf "${bold}*** updWallp (Version: $appVersion) ***${normal}\n\n"

checkOperatingSystem
checkImageMagick                             # function to check if ImageMagick is installed
checkupdWallpFolder                          # function to check if user configured the script folder
checkLocalOrRemoteMode                       # check if script runs in local or remote (muzei) mode

generateNewWallpaper                         # generates a new wallpaper
setLinuxWallpaper  "$outputFilename"         # set the linux wallpaper

cleanupUpdWallpDir                           # Cleaning up
