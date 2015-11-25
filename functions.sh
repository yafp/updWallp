#!/bin/bash
#
#  Name:       functions.sh
#  Function:   Contains the functions which all updWallp scripts might need
#  Github:     https://github.com/yafp/updWallp
#



# ---------------------------------------------------------------------
# Startroutine
# ---------------------------------------------------------------------
function startUp()
{
   clear
   printf "${bold}*** updWallp (Version: $appVersion) ***${normal}\n\n"
}



# ---------------------------------------------------------------------
# Checking the operating system
# ---------------------------------------------------------------------
function checkOperatingSystem()
{
   if [[ $OSTYPE = *linux* ]]
      then
         printf "${bold}${green}OK${normal} ... Operating system: $OSTYPE\n"
   else
         printf "${bold}${red}ERROR${normal} ... Unexpected operating system: $OSTYPE Aborting\n"
         exit
   fi
}



# ---------------------------------------------------------------------
# Check if imagemagick is installed
# ---------------------------------------------------------------------
function checkImageMagick() {
   if [ "$(which convert)" ]
   then
      printf "${bold}${green}OK${normal} ... Found ImageMagick\n"
   else
      printf "${bold}${red}ERROR${normal} ... ImageMagick not found\n"
      exit
   fi
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
      printf "${bold}${green}OK${normal} ... Found cURL (Muzei-Mode)\n"
   else
      printf "${bold}${red}ERROR${normal} ... cURL not found (Muzei-Mode). Aborting\n"
      exit
   fi

   # check for jq
   if [ "$(which jq)" ]
   then
      printf "${bold}${green}OK${normal} ... Found JQ (Muzei-Mode)\n"
   else
      printf "${bold}${red}ERROR${normal} ... JQ not found (Muzei-Mode). Aborting\n"
      exit
   fi
}



# ---------------------------------------------------------------------
# NOTIFICATION
# ---------------------------------------------------------------------
function displayNotification() {
   if [ "$enableNotifications" = true ]      # If notifications are enabled at all
      then
      if [ -f $notifyPath ];    # if notify-send exists
      then
         $notifyPath "$1" "$2" -i "$updWallpDir/img/appIcon_128px.png"
      else
         printf "${bold}${yellow}WARNING${normal} ... notify-send not found\n"
      fi
   fi
}




# ---------------------------------------------------------------------
# SETLINUXWALLPAPER
# ---------------------------------------------------------------------
function setLinuxWallpaper() {
   if [ "$(pidof gnome-settings-daemon)" ]
     then
       /usr/bin/gsettings set org.gnome.desktop.background picture-uri file://$updWallpDir/$1
       displayNotification "updWallp" "Wallpaper updated"
       printf "${bold}${green}OK${normal} ... Wallpaper set via gsettings\n"
     else
       if [ -f ~/.xinitrc ]
       then
         printf "${bold}${green}OK${normal} ... found ~/.xinitrc\n"
         if [ "$(which feh)" ]
         then
           printf "${bold}${green}OK${normal} ... Gnome-settings-daemons not running, setting wallpaper with feh\n"
           feh $outputFilename
           feh_xinitSet
         elif [ "$(which hsetroot)" ]
         then
           printf "${bold}${green}OK${normal} ... Gnome-settings-daemons not running, setting wallpaper with hsetroot\n"
           hsetroot -cover $outputFilename
           hsetroot_xinitSet
         elif [ "$(which nitrogen)" ]
         then
           printf "${bold}${green}OK${normal} ... Gnome-settings-daemons not running, setting wallpaper with nitrogen\n"
           nitrogen $outputFilename
           nitrogen_xinitSet
         else
           printf "${bold}${red}ERROR${normal} ... You need to have either feh, hsetroot or nitrogen, bruhbruh.\n"
           exit
         fi
       else
         printf "${bold}${red}ERROR${normal} ... You should have a ~/.xinitrc file\n"
         printf "${bold}${red}ERROR${normal} ... Was unable to set the wallpaper\n"
         exit
       fi
     fi
}




# ---------------------------------------------------------------------
# check if the path to the local image folder is valid
# Exit if the user submits a non-valid path
# ---------------------------------------------------------------------
function checkImageSourceFolder() {
   if [ -d "$imageSourcePath" ];                                                 # if image source folder exists
      then
      printf "${bold}${green}OK${normal} ... Image folder: $imageSourcePath is valid\n"      # can continue
      getNewRandomLocalFilePath                                                  # get a new local filepath
   else
      printf "${bold}${red}ERROR${normal} ... Local mode but image dir isnt a valid directory. Aborting\n"      # can continue
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
         printf "${bold}${green}OK${normal} ... There is a new Muzei image available. Loading it.\n"
      else
         rm muzeich2.json
         printf "${bold}${green}OK${normal} ... There is no new Muzei image available. Nothing to do here.\n"
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
   printf "${bold}${green}OK${normal} ... Finished getting latest Muzei image.\n"
}






# ---------------------------------------------------------------------
# SELECT A RANDOM LOCAL FILE FROM USER SUPPLIED PATH
# ---------------------------------------------------------------------
function getNewRandomLocalFilePath()
{
   newImage=$(find $imageSourcePath -type f | shuf -n 1)             # pick random image from source folder
   printf "${bold}${green}OK${normal} ... Selected a new random image from local folder\n"
}





# ---------------------------------------------------------------------
# GENERATE CURRENT IMAGES IN WORKING DIR
# ---------------------------------------------------------------------
function generateNewWallpaper()
{
   convert "$newImage" $backupFilename                               # copy random base image to project folder

   if [ "$enableGrayscaleMode" = true ]      # Specialmode 1: if Grayscale is enabled in config
      then
      convert "$newImage" $blurCommand $dimCommand $grayscaleCommand  $outputFilename     # Create a dimmed & blur-verion of the image into the working dir
      printf "${bold}${green}OK${normal} ... Generated the new grayscale wallpaper in $updWallpDir\n"
      return
   elif [ "$enableSepiaMode" = true ]        # Specialmode 2: if Sepia is enabled in config
      then
      convert "$newImage" $blurCommand $dimCommand $sepiaCommand  $outputFilename     # Create a dimmed & blur-verion of the image into the working dir
      printf "${bold}${green}OK${normal} ... Generated the new sepia wallpaper in $updWallpDir\n"
      return
   else                                      # Normal mode
      convert "$newImage" $blurCommand $dimCommand  $outputFilename     # Create a dimmed & blur-verion of the image into the working dir
      printf "${bold}${green}OK${normal} ... Generated the new wallpaper in $updWallpDir\n"
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
   printf "${bold}${green}OK${normal} ... Finished cleaning up $updWallpDir\n"
}
