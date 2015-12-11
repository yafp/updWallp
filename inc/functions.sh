#!/bin/bash
#
#  Name:       functions.sh
#  Function:   Contains the functions which all updWallp scripts might need
#  Github:     https://github.com/yafp/updWallp
#



# ---------------------------------------------------------------------
# Name:         startUp
# Function:     Prints the output header
# Mode:
# ---------------------------------------------------------------------
function startUp()
{
    printf "${bold}*** ${cyan}$appName ${white} - $appSubTitle ***${normal}\n\n"
    hostname=$(hostname)
    logWallp "Starting $appName on $hostname"
}



# ---------------------------------------------------------------------
# Name:         checkOperatingSystem
# Function:     Checks if script is executored on a linux system
# Mode:
# ---------------------------------------------------------------------
function checkOperatingSystem()
{
    if [[ $OSTYPE = *linux* ]]; then # we are on linux - so continue checking
        #printf "${bold}${green}OK${normal}\tOperating system: $OSTYPE\n"
        checkLinuxDesktopEnvironment # Check which desktop environment is in use
        logWallp "Detected supported operating system."
    else # not linux -> not supported
        printf "${bold}${red}ERROR${normal}\tUnexpected operating system: $OSTYPE. Exiting (errorcode 99).\n"
        logWallp "Detected unsupported operating system. Exiting (errorcode 99)."
        exit 99
    fi
}



# ---------------------------------------------------------------------
# Name:             checkLinuxDesktopEnvironment
# Function:         Checking the Desktop environment
# Mode:
# ---------------------------------------------------------------------
function checkLinuxDesktopEnvironment()
{
	# output display-dimensions if possible
    # might be wrong on multi-desktop systems
	if hash xdpyinfo 2>/dev/null; then
		displayResolution=$(xdpyinfo  | grep dimensions)
		printf "${bold}${green}OK${normal}\tDisplay $displayResolution\n"
	fi

    # Gnome 3
    if [ "$(pidof gnome-settings-daemon)" ]; then
        message="Detected Gnome 3 (supported)"
        logWallp "$message"
        printf "${bold}${green}OK${normal}\t$message\n"
        return
    fi

    #  Gnome 2
    if hash gconftool-2 2>/dev/null; then
        message="Detected Gnome 2 (supported)"
        logWallp "$message"
        printf "${bold}${green}OK${normal}\t$message\n"
        return
    fi

    # something else - most likely not supported
    message="Unsupported desktop environment. It's getting experimental right now."
    logWallp "$message"
    printf "${bold}${yellow}WARNING${normal}\t$message\n"
}



# ---------------------------------------------------------------------
# Name:             checkImageMagick
# Function:         Check if imagemagick is installed
#                   Exits the script if check fails
# Mode:
# ---------------------------------------------------------------------
function checkImageMagick() {
    if hash convert 2>/dev/null; then
        message="Found ImageMagick (required)"
        logWallp "$message"
        #printf "${bold}${green}OK${normal}\t$message\n"
    else
        message="ImageMagick not found. Exiting (errorcode 99)."
        logWallp "$message"
        printf "${bold}${red}ERROR${normal}\t$message\n"
        exit 99
    fi
}





# ---------------------------------------------------------------------
# Name:             checkRemoteRequirements
# Function:         Check the package requirements for remote mode (aka muzei mode)
#                   - cURL
#                   - jq
# Mode:             remote
# ---------------------------------------------------------------------
function checkRemoteRequirements()
{
    if hash curl 2>/dev/null; then # check for curl
        message="Found cURL (required for remote-mode)"
        logWallp "$message"
        printf "${bold}${green}OK${normal}\t$message\n"
    else
        message="cURL not found (required for remote-mode). Exiting (errorcode 99)."
        logWallp "$message"
        printf "${bold}${red}ERROR${normal}\t$message\n"
        exit 99
    fi


    if hash jq 2>/dev/null; then # check for jq
        message="Found JQ (required for remote-mode)"
        logWallp "$message"
        printf "${bold}${green}OK${normal}\t$message\n"
    else
        message="JQ not found (required for remote-mode). Exiting (errorcode 99)."
        logWallp "$message"
        printf "${bold}${red}ERROR${normal}\t$message\n"
        exit 99
    fi
}



# ---------------------------------------------------------------------
# Name:             displayNotification
# Function:         displays desktop notifications via notify-send if enabld in config.sh
# Mode:             local & remote
# ---------------------------------------------------------------------
function displayNotification() {
    # If notifications are enabled at all &  if notify-send exists
    if [ "$enableNotifications" = true ] && [ -f $notifyPath ]; then
        $notifyPath "$1" "$2" -i "$installationPath/img/appIcon_128px.png"
    fi
}



# ---------------------------------------------------------------------
# Name:             checkImageSourceFolder
# Function:         check if the path to the local image folder is valid
#                   Exit if the user submits a non-valid path
# Mode:
# ---------------------------------------------------------------------
function checkImageSourceFolder() {
    if [ -d "$localUserImageFolder" ]; then # if image source folder exists
        logWallp "Image source folder: $localUserImageFolder is valid"
        #printf "${bold}${green}OK${normal}\tImage source folder: ${underline}$localUserImageFolder${normal} is valid\n"       # can continue
        getNewRandomLocalFilePath                                                  # get a new local filepath
    else
        logWallp "Local mode but image source dir $localUserImageFolder isn't a valid directory. Exiting (errorcode 99)."
        printf "${bold}${red}ERROR${normal}\tLocal mode but image source dir ${underline}$localUserImageFolder${normal} isn't a valid directory. Exiting (errorcode 99).\n"      # can continue
        exit 99
    fi
}



# ---------------------------------------------------------------------
# Name:             getRemoteMuzeiImage
# Function          Checks for latest muzei image and fetches it if needed
# Mode:             remote
# ---------------------------------------------------------------------
function getRemoteMuzeiImage()
{
    if ! [ -f ./muzeich.json ]; then
        curl -o muzeich.json 'https://muzeiapi.appspot.com/featured?cachebust=1'
        message="Downloaded muzei.json (initial)."
        logWallp "$message"
        printf "${bold}${green}OK${normal}\t$message\n"
    else
       curl -o muzeich2.json 'https://muzeiapi.appspot.com/featured?cachebust=1'
        message="Downloaded muzei.json (checking for changes)."
        logWallp "$message"
        printf "${bold}${green}OK${normal}\t$message\n"
        # there is a new muzei image available
        if [ "$(cmp muzeich.json muzeich2.json)" ]; then
          mv muzeich2.json muzeich.json
            message="There is a new Muzei image available. Loading it."
            logWallp "$message"
            printf "${bold}${green}OK${normal}\t$message\n"
        else # muzei offers still the same image
            rm muzeich2.json # remove the second json file
            message="There is no new Muzei image available. Nothing to do here."
            logWallp "$message"
            printf "${bold}${green}OK${normal}\t$message\n"
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

    message="Finished getting latest Muzei image."
    logWallp "$message"
    printf "${bold}${green}OK${normal}\t$message\n"
}




# ---------------------------------------------------------------------
# Name:             getNewRandomLocalFilePath
# Function:         Picks a random image from the local folder
# Mode:             local
# ---------------------------------------------------------------------
function getNewRandomLocalFilePath()
{
    #newImage=$(find $localUserImageFolder -type f | shuf -n 1)             # pick random image from source folder
    newImage=$(find $localUserImageFolder -type f \( -name '*.jpg' -o -name '*.JPG' -o -name '*.jpeg' -o -name '*.JPEG' -o -name '*.png' -o -name '*.PNG' \) | shuf -n 1)

    if ! [ -f "$localUserImageFolder/$newImage" ]; then #check if random picked file exists

        # if only landscape images should be used
        if [ "$useOnlyLandscapeImages" = true ]; then
            curImageWidth=$(identify -ping -format %W "$newImage")
            curImageHeight=$(identify -ping -format %H "$newImage")

            if [ "$curImageHeight" -gt "$curImageWidth" ]; then
                #printf "${bold}${green}OK${normal}\tRandom pick was in landscape-mode - continue\n"
            #else
                printf "${bold}${yellow}WARNING${normal}\tRandom pick was in portrait-mode - repick\n"
                getNewRandomLocalFilePath
                return
            fi
        fi

        logWallp "Random image: $newImage"
        printf "${bold}${green}OK${normal}\tRandom image: ${underline}$newImage${normal}\n"
    else
        logWallp "Random file ($newImage) was not an image. Exiting (errorcode 88)."
        printf "${bold}${red}ERROR${normal}\tRandom file ($newImage) was not an image. Exiting (errorcode 88).\n"
        exit 88
    fi
}





# ---------------------------------------------------------------------
# Name:             generateNewWallpaper
# Function:         generates the new wallpaper in the project folder
# Mode:             local & remote
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
		    2)  convert "$newImage" $blurCommand $dimCommand $sepiaCommand  $workInProgess     # Create a dimmed & blur-verion of the image into the working dir
			    printf "${bold}${green}OK${normal}\tGenerated the new sepia wallpaper in ${underline}$installationPath/tmp${normal}\n"
    			;;

            # 3 = colorize
   		    3)  convert "$newImage" $blurCommand $dimCommand $colorizeCommand  $workInProgess     # Create a dimmed & blur-verion of the image into the working dir
   			    printf "${bold}${green}OK${normal}\tGenerated the new colorized wallpaper in ${underline}$installationPath/tmp${normal}\n"
       		    ;;

            # 4 = levelColors
            4)  convert "$newImage" $blurCommand $dimCommand $levelColorsCommand  $workInProgess     # Create a dimmed & blur-verion of the image into the working dir
                printf "${bold}${green}OK${normal}\tGenerated the new level-colors wallpaper in ${underline}$installationPath/tmp${normal}\n"
                ;;

		    *)  printf "${bold}${red}ERROR${normal}\tImage modification mode is set to ${underline}$imageModificationMode${normal} which isnt correct. Aborting\n"
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
        # -> avoids flickering while script-execution
        convert $workInProgess $outputFilename

        return
	fi
}



# ---------------------------------------------------------------------
# Name:             setLinuxWallpaper
# Function:         Tries to set the new generated image as new wallpaper
# Mode:             local and remote
# ---------------------------------------------------------------------
function setLinuxWallpaper() {

    # setting wallpaper on Gnome 3
    if [ "$(pidof gnome-settings-daemon)" ]; then
        /usr/bin/gsettings set org.gnome.desktop.background picture-uri file://$installationPath/$1
        displayNotification "$appName" "Wallpaper updated (using gsettings on Gnome 3)"
        message="Wallpaper updated (using gsettings on Gnome 3)"
        logWallp "$message"
        printf "${bold}${green}OK${normal}\t$message\n"
        return
    fi

    # Setting wallpaper on Gnome 2
    if hash gconftool-2 2>/dev/null; then
        gconftool-2 --type=string --set /desktop/gnome/background/picture_filename $installationPath/$1
        displayNotification "$appName" "Wallpaper updated (using gconftool on Gnome 2)"
        message="Wallpaper updated (using gconftool on Gnome 2)"
        logWallp "$message"
        printf "${bold}${green}OK${normal}\t$message\n"
        return
    fi

    message="No supported desktop environment detected. Starting experimental tests"
    logWallp "$message"
    printf "${bold}${yellow}WARNING${normal}\t$message\n"


    if hash feh 2>/dev/null; then
        printf "${bold}${green}OK${normal}\tDetected feh\n"
        feh --bg-max $installationPath/$1
        printf "${bold}${green}OK${normal}\tWallpaper updated (using feh)\n"
        return
    fi

    printf "${bold}${red}ERROR${normal}\tSorry but your system is not supported.\n"
    printf "${bold}${red}ERROR${normal}\tCurrently only Gnome is supported (using: gsettings and/or gconftool-2 - feh is used if available for nonsupported environments)\n"
    printf "${bold}${red}ERROR${normal}\tTry installing 'feh' and then re-run the script again.\n"
    printf "${bold}${red}ERROR${normal}\tMore: ${underline}$appDocURL/Supported-Desktop-Environments${normal}. Exiting (errorcode 99).\n"
    exit 99
}




# ---------------------------------------------------------------------
# Name:             logWallp
# Function:         Is writing the logfile
#                   logging mode must be configured in config.sh
# Mode:             local and remote
# ---------------------------------------------------------------------
function logWallp()
{
    timestamp=$(date +"%Y%m%d-%T")

    case $loggingMode in
      0)
        # logging is disabled
        return
        ;;

      1)
        # syslog via logger
        if hash feh 2>/dev/null; then
            logger "$1"
        fi
        return
        ;;

      2)
        # self-written logging method
        printf "$timestamp\t\t$1\n" >> "$installationPath/logs/updWallpLog.txt"
        return
        ;;

      *)
        printf "${bold}${yellow}WARNING${normal}\tYou have misconfigured ${underline}loggingMode${normal} in config.sh with an value of: ${underline}$loggingMode${normal}.\n"
        return
        ;;
   esac
}


# ---------------------------------------------------------------------
# Name:             printfWallp
# Function:         Does the output to the commandline
# ---------------------------------------------------------------------
function printfWallp()
{
    messageType="$1"
    messageText="$2"
    messageHead=""

    case $messageType in
        1)
            # ok / info
            messageHead="${bold}${green}OK${normal}\t"
            ;;

        2)
            # warning
            messageHead="${bold}${yellow}WARNING${normal}\t"
            ;;

        3)
            # error
            messageHead="${bold}${red}ERROR${normal}\t"
            ;;
    esac

    printf "$messageHead"
    printf "$messageText"
}



# ---------------------------------------------------------------------
# Name:             cleanupUpdWallpDir
# Function:         Clean the app folder at the end of the processing
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
    #printfWallp "1" "Finished cleaning up."

    logWallp "Finished cleaning up."
    logWallp "updWallp says goodbye.\n\n"
}
