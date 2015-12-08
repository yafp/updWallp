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
   printf "${bold}*** $appName ${normal}(Version: $appVersion) ${bold}***${normal}\n\n"
}



# ---------------------------------------------------------------------
# Checking the operating system
# ---------------------------------------------------------------------
function checkOperatingSystem()
{
   # we are on linux - so continue checking
   if [[ $OSTYPE = *linux* ]]; then
      printf "${bold}${green}OK${normal}\tOperating system: $OSTYPE\n"
      checkLinuxDesktopEnvironment # Check which desktop environment is in use
   else # not linux -> not supported
      printf "${bold}${red}ERROR${normal}\tUnexpected operating system: $OSTYPE. Exiting (errorcode 99).\n"
      exit 99
   fi
}



# ---------------------------------------------------------------------
# Checking the Desktop environment
# ---------------------------------------------------------------------
function checkLinuxDesktopEnvironment()
{
	# output display dimensions if possible
	if hash xdpyinfo 2>/dev/null; then
		displayResolution=$(xdpyinfo  | grep dimensions)
		printf "${bold}${green}OK${normal}\tDisplay $displayResolution\n"
	fi


   # Check: is it gnome 3?
   if [ "$(pidof gnome-settings-daemon)" ]; then
      printf "${bold}${green}OK${normal}\tDetected Gnome 3 (supported)\n"
      return
   fi

   #  Check: is it gnome 2?
   if hash gconftool-2 2>/dev/null; then
      printf "${bold}${green}OK${normal}\tDetected Gnome 2 (supported)\n"
      return
   fi

   # something else - most likely not supported
   printf "${bold}${yellow}WARNING${normal}\tUnsupported desktop environment. It's getting experimental right now.\n"
}



# ---------------------------------------------------------------------
# Check if imagemagick is installed
# ---------------------------------------------------------------------
function checkImageMagick() {
   if hash convert 2>/dev/null; then
      printf "${bold}${green}OK${normal}\tFound ImageMagick (required)\n"
   else
      printf "${bold}${red}ERROR${normal}\tImageMagick not found. Exiting (errorcode 99).\n"
      exit 99
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
   if hash curl 2>/dev/null; then
      printf "${bold}${green}OK${normal}\tFound cURL (required for remote-mode)\n"
   else
      printf "${bold}${red}ERROR${normal}\tcURL not found (required for remote-mode). Exiting (errorcode 99).\n"
      exit 99
   fi

   # check for jq
   if hash jq 2>/dev/null; then
      printf "${bold}${green}OK${normal}\tFound JQ (required for remote-mode)\n"
   else
      printf "${bold}${red}ERROR${normal}\tJQ not found (required for remote-mode). Exiting (errorcode 99).\n"
      exit 99
   fi
}



# ---------------------------------------------------------------------
# NOTIFICATION (enable or disable via config.sh)
# ---------------------------------------------------------------------
function displayNotification() {
   # If notifications are enabled at all &  if notify-send exists
   if [ "$enableNotifications" = true ] && [ -f $notifyPath ]; then
      $notifyPath "$1" "$2" -i "$installationPath/img/appIcon_128px.png"
   fi
}



# ---------------------------------------------------------------------
# check if the path to the local image folder is valid
# Exit if the user submits a non-valid path
# ---------------------------------------------------------------------
function checkImageSourceFolder() {
   # if image source folder exists
   if [ -d "$localUserImageFolder" ]; then
      printf "${bold}${green}OK${normal}\tImage source folder: ${underline}$localUserImageFolder${normal} is valid\n"       # can continue
      getNewRandomLocalFilePath                                                  # get a new local filepath
   else
      printf "${bold}${red}ERROR${normal}\tLocal mode but image source dir ${underline}$localUserImageFolder${normal} isnt a valid directory. Exiting (errorcode 99).\n"      # can continue
      exit 99
   fi
}



# ---------------------------------------------------------------------
# GETREMOTEMUZEIIMAGE
# ---------------------------------------------------------------------
function getRemoteMuzeiImage()
{
   if ! [ -f ./muzeich.json ]; then
      curl -o muzeich.json 'https://muzeiapi.appspot.com/featured?cachebust=1'
      printf "${bold}${green}OK${normal}\tDownloaded muzei.json (initial).\n"
   else
      curl -o muzeich2.json 'https://muzeiapi.appspot.com/featured?cachebust=1'
      printf "${bold}${green}OK${normal}\tDownloaded muzei.json (checking for changes).\n"
      # there is a new muzei image available
      if [ "$(cmp muzeich.json muzeich2.json)" ]; then
         mv muzeich2.json muzeich.json
         printf "${bold}${green}OK${normal}\tThere is a new Muzei image available. Loading it.\n"
      else # muzei offers still the same image
         rm muzeich2.json # remove the second json file
         printf "${bold}${green}OK${normal}\tThere is no new Muzei image available. Nothing to do here.\n"
         exit
      fi
   fi

   # parse the Muzei JSON to extract the new image url
   imageUri=`jq '.imageUri' $installationPath/muzeich.json | sed s/\"//g`
   imageFile=`basename $imageUri`
   title=`jq '.title' $installationPath/muzeich.json | sed s/\"//g`
   byline=`jq '.byline' $installationPath/muzeich.json | sed s/\"//g`

   echo "File $imageFile does not exist, downloading..."
   curl -O $imageUri
   convert $imageFile $muzeiFilename

   newImage=$installationPath/$muzeiFilename
   printf "${bold}${green}OK${normal}\tFinished getting latest Muzei image.\n"
}






# ---------------------------------------------------------------------
# SELECT A RANDOM LOCAL FILE FROM USER SUPPLIED PATH
#     only: .jpg, .jpeg, .png are accepted image formats so far.
# ---------------------------------------------------------------------
function getNewRandomLocalFilePath()
{
   #newImage=$(find $localUserImageFolder -type f | shuf -n 1)             # pick random image from source folder
   newImage=$(find $localUserImageFolder -type f \( -name '*.jpg' -o -name '*.JPG' -o -name '*.jpeg' -o -name '*.JPEG' -o -name '*.png' -o -name '*.PNG' \) | shuf -n 1)

   if ! [ -f "$localUserImageFolder/$newImage" ]; then #check if random picked file exists
      printf "${bold}${green}OK${normal}\tRandom image: ${underline}$newImage${normal}\n"
   else
      printf "${bold}${red}ERROR${normal}\tRandom file ($newImage) was not an image. Exiting (errorcode 88)\n"
      exit 88
   fi
}





# ---------------------------------------------------------------------
# GENERATE CURRENT IMAGES IN WORKING DIR
# ---------------------------------------------------------------------
function generateNewWallpaper()
{
   convert "$newImage" $backupFilename                               # copy random base image to project folder (using convert to ensure its always a png)
   printf "${bold}${green}OK${normal}\tFinished mirroring source image to ${underline}$installationPath/$backupFilename${normal}\n"


	#$imageModificationMode
	if [ -z "$imageModificationMode" ]; then
		printf "${bold}${red}ERROR${normal}\tImage modification mode is not set, Please check ${underline}config.sh${normal}. Aborting\n"
		exit 99
	else # mode is set - now check if its valid
		case "$imageModificationMode" in

         # 0 = normal-mode
			0) convert "$newImage" $blurCommand $dimCommand  $workInProgess     # Create a dimmed & blur-verion of the image into the working dir
				printf "${bold}${green}OK${normal}\tGenerated the new plain wallpaper in ${underline}$installationPath/tmp${normal}\n"
    			;;

         # 1 = grayscale
			1) convert "$newImage" $blurCommand $dimCommand $grayscaleCommand  $workInProgess     # Create a dimmed & blur-verion of the image into the working dir
   		   printf "${bold}${green}OK${normal}\tGenerated the new grayscaled wallpaper in ${underline}$installationPath/tmp${normal}\n"
            ;;

         # 2 = sepia-mode
			2) convert "$newImage" $blurCommand $dimCommand $sepiaCommand  $workInProgess     # Create a dimmed & blur-verion of the image into the working dir
				printf "${bold}${green}OK${normal}\tGenerated the new sepia wallpaper in ${underline}$installationPath/tmp${normal}\n"
    			;;

         # 3 = colorize
   		3) convert "$newImage" $blurCommand $dimCommand $colorizeCommand  $workInProgess     # Create a dimmed & blur-verion of the image into the working dir
   			printf "${bold}${green}OK${normal}\tGenerated the new colorized wallpaper in ${underline}$installationPath/tmp${normal}\n"
       		;;

         # 4 = levelColors
      	4) convert "$newImage" $blurCommand $dimCommand $levelColorsCommand  $workInProgess     # Create a dimmed & blur-verion of the image into the working dir
      		printf "${bold}${green}OK${normal}\tGenerated the new level-colors wallpaper in ${underline}$installationPath/tmp${normal}\n"
         	;;

			*) printf "${bold}${red}ERROR${normal}\tImage modification mode is set to ${underline}$imageModificationMode${normal} which isnt correct. Aborting\n"
				exit 99
   			;;
		esac

      # scale image to user-defined with if configured in config.sh
      if [ "$enableScaleToWidth" = true ]; then
         convert $workInProgess -thumbnail $imageWidth $workInProgess     # Create a dimmed & blur-verion of the image into the working dir
         printf "${bold}${green}OK${normal}\tScaled image to defined width of ${underline}$imageWidth${normal} pixel.\n"
      fi

      # Add Label if configured (testing)
      if [ "$addAppLabelOnGeneratedWallpaper" = true ] ; then
         #imageDimensions=$(identify -size geometry)
         #printf "$imageDimensions\n"
         composite -geometry  +0+1200 "img/appLabel_150x40px.png" $workInProgess $workInProgess
         printf "${bold}${green}OK${normal}\tAdded app-label to ${underline}$installationPath/$outputFilename${normal}\n"
      fi

      # image creation is done - rename work-in-progress-file to final filename for new wallpaper
      # this avoids sideeffects / racing conditions if we write several time to the filename which is in use at the same time
      # -> avaoids flickering while script-execution
      convert $workInProgess $outputFilename

      return
	fi
}



# ---------------------------------------------------------------------
# SETLINUXWALLPAPER
# ---------------------------------------------------------------------
function setLinuxWallpaper() {

   # setting wallpaper on Gnome 3
   if [ "$(pidof gnome-settings-daemon)" ]; then
      /usr/bin/gsettings set org.gnome.desktop.background picture-uri file://$installationPath/$1
      displayNotification "$appName" "Wallpaper updated (using gsettings on Gnome 3)"
      printf "${bold}${green}OK${normal}\tWallpaper updated (using gsettings on Gnome 3)\n"
      return
   fi

   # Setting wallpaper on Gnome 2
   if hash gconftool-2 2>/dev/null; then
      gconftool-2 --type=string --set /desktop/gnome/background/picture_filename $installationPath/$1
      displayNotification "$appName" "Wallpaper updated (using gconftool on Gnome 2)"
      printf "${bold}${green}OK${normal}\tWallpaper updated (using gconftool on Gnome 2)\n"
      return
   fi

   printf "${bold}${yellow}WARNING${normal}\tNo supported desktop environment detected. Starting experimental tests\n"


   if hash feh 2>/dev/null; then
      printf "${bold}${green}OK${normal}\tDetected feh\n"
      feh --bg-max $installationPath/$1
      printf "${bold}${green}OK${normal}\tWallpaper updated (using feh)\n"
      return
   fi

   printf "${bold}${red}ERROR${normal}\tSorry but your system is not supported.\n"
   printf "${bold}${red}ERROR${normal}\tCurrently only Gnome is supported (using: gsettings and/or gconftool-2 - feh is used for nonsupported environments)\n"
   printf "${bold}${red}ERROR${normal}\tMore: ${underline}$appDocURL/Supported-Desktop-Environments${normal}. Exiting (errorcode 99).\n"
   exit 99
}




# ---------------------------------------------------------------------
# Clean the app folder at the end of the processing
# ---------------------------------------------------------------------
function cleanupUpdWallpDir()
{
   if [ -f "$imageFile" ]; then
      rm $imageFile # from remote mode: org muzei name with org name
   fi

   if [ -f "$workInProgess" ];then
      rm $workInProgess
   fi

   printf "${bold}${green}OK${normal}\tFinished cleaning up ${underline}$installationPath${normal}. Goodbye\n"
}
