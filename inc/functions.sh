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
	# output display dimensions if possible
	if [ "$(which xdpyinfo)" ]; then
		displayResolution=$(xdpyinfo  | grep dimensions)
		printf "${bold}${green}OK${normal} ... Display $displayResolution\n"
	fi
	
   #desktopEnv=$DESKTOP_SESSION
   ##desktopEnv=$XDG_CURRENT_DESKTOP
   # optional using: $XDG_CURRENT_DESKTOP

   #printf "Detected Desktop: $desktopEnv\n\n"

   # possible answers:
   #
   # - gnome 3    = gnome
   # - xfce4      = xfce4
   # - KDE        = ?

   ##case  $desktopEnv  in
      ##"GNOME")
         # Check: is it gnome3?
         if [ "$(pidof gnome-settings-daemon)" ]; then
               printf "${bold}${green}OK${normal} ... Gnome 3 is supported\n"
            return
         fi

         if [ "$(which gconftool-2)" ]; then
               printf "${bold}${green}OK${normal} ... Gnome 2 is supported\n"
            return
         fi

         printf "${bold}${red}ERROR${normal} ... Unsupported desktop environment. Aborting\n"
         exit
         ##;;

      ##*)
      ##   printf "${bold}${red}ERROR${normal} ... Unsupported Desktop Envorinment detected ($desktopEnv).\n"
      ##   printf "${bold}${red}ERROR${normal} ... Currently only Gnome 2 & 3 are supported.\n"
      ##   printf "${bold}${red}ERROR${normal} ... More: ${underline}https://github.com/yafp/updWallp/wiki/Supported-Desktop-Environments${normal}. Aborting\n"
      ##   exit
   ##esac
}



# ---------------------------------------------------------------------
# Check if imagemagick is installed
# ---------------------------------------------------------------------
function checkImageMagick() {
   if [ "$(which convert)" ]; then
      printf "${bold}${green}OK${normal} ... Found ImageMagick\n"
   else
      printf "${bold}${red}ERROR${normal} ... ImageMagick not found\n"
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
   if [ "$(which curl)" ]; then
      printf "${bold}${green}OK${normal} ... Found cURL (remote-mode)\n"
   else
      printf "${bold}${red}ERROR${normal} ... cURL not found (remote-mode). Aborting\n"
      exit 99
   fi

   # check for jq
   if [ "$(which jq)" ]; then
      printf "${bold}${green}OK${normal} ... Found JQ (remote-mode)\n"
   else
      printf "${bold}${red}ERROR${normal} ... JQ not found (remote-mode). Aborting\n"
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
# SETLINUXWALLPAPER
# ---------------------------------------------------------------------
function setLinuxWallpaper() {

   # setting wallpaper on Gnome 3
   if [ "$(pidof gnome-settings-daemon)" ]; then
         /usr/bin/gsettings set org.gnome.desktop.background picture-uri file://$installationPath/$1
         displayNotification "$appName" "Wallpaper updated (using gsettings on Gnome 3)"
         printf "${bold}${green}OK${normal} ... Wallpaper updated (using gsettings on Gnome 3)\n"
         return
   fi

   # Setting wallpaper on Gnome 2
   if [ "$(which gconftool-2)" ]; then
         gconftool-2 --type=string --set /desktop/gnome/background/picture_filename $installationPath/$1
         displayNotification "$appName" "Wallpaper updated (using gconftool on Gnome 2)"
         printf "${bold}${green}OK${normal} ... Wallpaper updated (using gconftool on Gnome 2)\n"
         return
   fi

   printf "${bold}${red}ERROR${normal} ... Sorry dude but your system is not supported.\n"
   printf "${bold}${red}ERROR${normal} ... Currently only Gnome is supported (using: gsettings)\n"
   printf "${bold}${red}ERROR${normal} ... More: ${underline}https://github.com/yafp/updWallp/wiki/Supported-Desktop-Environments${normal}. Aborting\n"
   exit
}




# ---------------------------------------------------------------------
# check if the path to the local image folder is valid
# Exit if the user submits a non-valid path
# ---------------------------------------------------------------------
function checkImageSourceFolder() {
   # if image source folder exists
   if [ -d "$localUserImageFolder" ]; then
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
   if ! [ -f ./muzeich.json ]; then
      curl -o muzeich.json 'https://muzeiapi.appspot.com/featured?cachebust=1'
      printf "${bold}${green}OK${normal} ... Downloaded muzei.json (initial).\n"
   else
      curl -o muzeich2.json 'https://muzeiapi.appspot.com/featured?cachebust=1'
      printf "${bold}${green}OK${normal} ... Downloaded muzei.json (checking for changes).\n"
      # there is a new muzei image available
      if [ "$(cmp muzeich.json muzeich2.json)" ]; then
         mv muzeich2.json muzeich.json
         printf "${bold}${green}OK${normal} ... There is a new Muzei image available. Loading it.\n"
      else # muzei offers still the same image
         rm muzeich2.json # remove the second json file
         printf "${bold}${green}OK${normal} ... There is no new Muzei image available. Nothing to do here.\n"
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
   convert "$newImage" $backupFilename                               # copy random base image to project folder (using convert to ensure its always a png)

	#$imageModificationMode
	if [ -z "$imageModificationMode" ]; then
		printf "${bold}${red}ERROR${normal} ... Image modification mode is not set, Please check ${underline}config.sh${normal}. Aborting\n"
		exit 99
	else # mode is set - now check if its valid
		case "$imageModificationMode" in
			0)  convert "$newImage" $blurCommand $dimCommand  $outputFilename     # Create a dimmed & blur-verion of the image into the working dir
				printf "${bold}${green}OK${normal} ... Generated the new plain wallpaper in ${underline}$installationPath${normal}\n"
    			;;
			1)  convert "$newImage" $blurCommand $dimCommand $grayscaleCommand  $outputFilename     # Create a dimmed & blur-verion of the image into the working dir
				printf "${bold}${green}OK${normal} ... Generated the new grayscale wallpaper in ${underline}$installationPath${normal}\n"
				
				# Label command
				if [ "$addAppLabelOnGeneratedWallpaper" = true ] ; then
					composite -geometry  +0+700 "img/appLabel.png" $outputFilename $outputFilename
					printf "${bold}${green}OK${normal} ... Added an app-label\n"
				fi
			
				
				
    			;;
			2)  convert "$newImage" $blurCommand $dimCommand $sepiaCommand  $outputFilename     # Create a dimmed & blur-verion of the image into the working dir
				printf "${bold}${green}OK${normal} ... Generated the new sepia wallpaper in ${underline}$installationPath${normal}\n"
    			;;
			*) 	printf "${bold}${red}ERROR${normal} ... Image modification mode is set to ${underline}$imageModificationMode${normal} which isnt correct. Aborting\n"
				exit 99
   				;;
		esac
	fi
}



# ---------------------------------------------------------------------
# Clean the app folder at the end of the processing
# ---------------------------------------------------------------------
function cleanupUpdWallpDir()
{
   if [ -f "$imageFile" ]; then
      rm $imageFile
   fi

   #if [ -f "$muzeiFilename" ]
      #then
      #rm $muzeiFilename
   #fi

   printf "${bold}${green}OK${normal} ... Finished cleaning up ${underline}$installationPath${normal}. Goodbye\n"
}
