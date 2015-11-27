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
   if [[ $OSTYPE = *linux* ]] # we are on linux - so continue checking
      then
      printf "${bold}${green}OK${normal} ... Operating system: $OSTYPE\n"
      checkLinuxDesktopEnvironment # Check which desktop environment is in use

   else # not linux -> not supported
      printf "${bold}${red}ERROR${normal} ... Unexpected operating system: $OSTYPE Aborting\n"
      exit
   fi
}



# ---------------------------------------------------------------------
# Checking the Desktop environment
# ---------------------------------------------------------------------
function checkLinuxDesktopEnvironment()
{
   desktopEnv=$DESKTOP_SESSION

   # possible answers:
   #
   # - gnome 3    = gnome
   # - xfce4      = xfce4
   # - KDE        = ?

   case  $desktopEnv  in
      "gnome")
         # Is Supported - Nothing to do here
         if [ "$(which gnome-session)" ]
            then
            gnomeVersion="$(gnome-session --version)" # Get Gnome Version
            printf "${bold}${green}OK${normal} ... Detected: ${gnomeVersion}\n"

            # Gnome 3.x?
            if [[ $gnomeVersion == *"gnome-session 3."* ]]
               then
               printf "${bold}${green}OK${normal} ... Gnome 3 is supported\n"
               return
            fi

            # Gnome 2.x?
            if [[ $gnomeVersion == *"gnome-session 2."* ]]
               then
               printf "${bold}${green}OK${normal} ... Gnome 2 is supported\n"
               return
            fi

            # if this code is reached - it seems to be gnome - but beither Gnome2 nor Gnome3 - Unexpected - exit
            printf "${bold}${red}ERROR${normal} ... Unsupported Gnome Version. Aborting\n"
            exit
         fi
         ;;

      *)
         printf "${bold}${red}ERROR${normal} ... Unsupported Desktop Envorinment detected ($desktopEnv).\n"
         printf "${bold}${red}ERROR${normal} ... Currently only Gnome 2 & 3 are supported.\n"
         printf "${bold}${red}ERROR${normal} ... More: ${underline}https://github.com/yafp/updWallp/wiki/Supported-Desktop-Environments${normal}. Aborting\n"
         exit
   esac
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
      printf "${bold}${green}OK${normal} ... Found cURL (remote-mode)\n"
   else
      printf "${bold}${red}ERROR${normal} ... cURL not found (remote-mode). Aborting\n"
      exit
   fi

   # check for jq
   if [ "$(which jq)" ]
      then
      printf "${bold}${green}OK${normal} ... Found JQ (remote-mode)\n"
   else
      printf "${bold}${red}ERROR${normal} ... JQ not found (remote-mode). Aborting\n"
      exit
   fi
}



# ---------------------------------------------------------------------
# NOTIFICATION (enable or disable via config.sh)
# ---------------------------------------------------------------------
function displayNotification() {
   if [ "$enableNotifications" = true ]      # If notifications are enabled at all
      then
      if [ -f $notifyPath ];    # if notify-send exists
         then
         $notifyPath "$1" "$2" -i "$updWallpDir/img/appIcon_128px.png"
      else
         printf "${bold}${yellow}WARNING${normal} ... Unable to display a notification (notify-send not found)\n"
      fi
   fi
}




# ---------------------------------------------------------------------
# SETLINUXWALLPAPER
# ---------------------------------------------------------------------
function setLinuxWallpaper() {
   if [ "$(which gnome-session)" ]
      then
      gnomeVersion="$(gnome-session --version)" # Get Gnome Version

      # Gnome 3.x?
      if [[ $gnomeVersion == *"gnome-session 3."* ]]
         then
         #printf "${bold}${green}OK${normal} ... Gnome 3\n"
         if [ "$(pidof gnome-settings-daemon)" ];
            then
            /usr/bin/gsettings set org.gnome.desktop.background picture-uri file://$updWallpDir/$1
            displayNotification "updWallp" "Wallpaper updated (using gsettings on Gnome 3)"
            printf "${bold}${green}OK${normal} ... Wallpaper updated (using gsettings on Gnome 3)\n"
            return
         fi
      fi

      # Gnome 2.x?
      if [[ $gnomeVersion == *"gnome-session 2."* ]]
         then
         gconftool-2 --type=string --set /desktop/gnome/background/picture_filename $updWallpDir/$1
         displayNotification "updWallp" "Wallpaper updated (using gconftool on Gnome 2)"
         printf "${bold}${green}OK${normal} ... Wallpaper updated (using gconftool on Gnome 2)\n"
         return
      fi

      # if this code is reached - it seems to be gnome - but neither Gnome2 nor Gnome3 - Unexpected - exit
      printf "${bold}${red}ERROR${normal} ... Unsupported Gnome Version. Aborting\n"
      exit

   else # its for sure not gnome which is used here
      printf "${bold}${red}ERROR${normal} ... Sorry dude but your system is not supported.\n"
      printf "${bold}${red}ERROR${normal} ... Currently only Gnome is supported (using: gsettings)\n"
      printf "${bold}${red}ERROR${normal} ... More: ${underline}https://github.com/yafp/updWallp/wiki/Supported-Desktop-Environments${normal}. Aborting\n"
      exit
   fi
}




# ---------------------------------------------------------------------
# check if the path to the local image folder is valid
# Exit if the user submits a non-valid path
# ---------------------------------------------------------------------
function checkImageSourceFolder() {
   if [ -d "$localUserImageFolder" ];                                                              # if image source folder exists
      then
      printf "${bold}${green}OK${normal} ... Image source folder: ${underline}$localUserImageFolder${normal} is valid\n"       # can continue
      getNewRandomLocalFilePath                                                  # get a new local filepath
   else
      printf "${bold}${red}ERROR${normal} ... Local mode but image source dir ${underline}$localUserImageFolder${normal} isnt a valid directory. Aborting\n"      # can continue
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
      printf "${bold}${green}OK${normal} ... Downloaded muzei.json (initial).\n"
   else
      curl -o muzeich2.json 'https://muzeiapi.appspot.com/featured?cachebust=1'
      printf "${bold}${green}OK${normal} ... Downloaded muzei.json (checking for changes).\n"
      if [ "$(cmp muzeich.json muzeich2.json)" ] # there is a new muzei image available
         then
         mv muzeich2.json muzeich.json
         printf "${bold}${green}OK${normal} ... There is a new Muzei image available. Loading it.\n"

      else # muzei offers still the same image
         rm muzeich2.json # remove the second json file
         printf "${bold}${green}OK${normal} ... There is no new Muzei image available. Nothing to do here.\n"
         exit
      fi
   fi

   # parse the Muzei JSON to extract the new image url
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
   newImage=$(find $localUserImageFolder -type f | shuf -n 1)             # pick random image from source folder
   printf "${bold}${green}OK${normal} ... Random local image choosen\n"
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

   #if [ -f "$muzeiFilename" ]
      #then
      #rm $muzeiFilename
   #fi

   printf "${bold}${green}OK${normal} ... Finished cleaning up ${underline}$updWallpDir${normal}\n"
}
