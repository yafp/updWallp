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
    printf "##########################################################\n"
    printf "# ${bold}$appName - $appSubTitle ${normal}\n"
    printf "##########################################################\n\n"

    hostname=$(hostname)
    logWallp "Starting $appName on $hostname"
}



# ---------------------------------------------------------------------
# Name:         validateConfig
# Function:     Checks the content of config.sh
# Mode:         local and remote
# ---------------------------------------------------------------------
function validateConfig()
{
    printf "${bold}${green}OK${normal}\tStarting config validation...\n"

    # check installationPath
    #
    if [ -z "$installationPath" ]; then
        printf "${bold}${red}ERROR${normal}\tMisconfigured installation path (installationPath in config.sh is unset). Exiting (errno 2).\n"
        exit 2
    else
        if [ -d "$installationPath" ]; then
            printf "${bold}${green}OK${normal}\tInstallation path is valid: $installationPath\n"
        else
            printf "${bold}${red}ERROR${normal}\tMisconfigured installation path (installationPath in config.sh). Exiting (errno 2).\n"
            exit 2
        fi
    fi


    # check operation mode
    #
    if [ -z "$operationMode" ]; then
        printf "${bold}${red}ERROR${normal}\tMisconfigured operation mode (operationMode in config.sh is unset). Exiting (errno 99).\n"
        exit 99
    else
        if [ "$operationMode" = "1" ] || [ "$operationMode" = "2" ] ; then
            printf "${bold}${green}OK${normal}\tOperation mode: $operationMode\n"

            if [ "$operationMode" = "1" ]; then
                if [ -z "$localImageFolder" ]; then
                    printf "${bold}${red}ERROR${normal}\tMisconfigured local image folder (localImageFolder in config.sh is unset). Exiting (errno 99).\n"
                    exit 99
                else
                    if [ -d "$localImageFolder" ]; then
                        printf "${bold}${green}OK${normal}\tLocal image folder: $localImageFolder\n"
                    else
                        printf "${bold}${red}ERROR${normal}\tMisconfigured local image folder (localImageFolder in config.sh is not valid). Exiting (errno 99).\n"
                        exit 99
                    fi
                fi
            fi
        else
            printf "${bold}${red}ERROR${normal}\tMisconfigured operation mode (operationMode in config.sh). Exiting (errno 99).\n"
            exit 99
        fi
    fi

    # check modification mode
    if [ -z "$imageModificationMode" ]; then
        printf "${bold}${red}ERROR${normal}\tMisconfigured modification mode (imageModificationMode in config.sh is unset). Exiting (errno 99).\n"
        exit 99
    else
        if [ "$imageModificationMode" = "0" ] || [ "$imageModificationMode" = "1" ] || [ "$imageModificationMode" = "2" ] || [ "$imageModificationMode" = "3" ] || [ "$imageModificationMode" = "4" ] ; then
            printf "${bold}${green}OK${normal}\tModification mode: $imageModificationMode\n"
        fi
    fi

    printf "${bold}${green}OK${normal}\tFinished config validation. Everything looks fine.\n"
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
        validateConfig
        checkResolution # Check which desktop environment is in use
        logWallp "Detected supported operating system."
    else # not linux -> not supported
        printf "${bold}${red}ERROR${normal}\tUnexpected operating system: $OSTYPE. Exiting (errorcode 99).\n"
        logWallp "Detected unsupported operating system. Exiting (errorcode 99)."
        exit 99
    fi


}



# ---------------------------------------------------------------------
# Name:             checkResolution
# Function:         Checking the resolution
# Mode:
# ---------------------------------------------------------------------
function checkResolution()
{
	# output display-dimensions if possible
    # might be wrong on multi-desktop systems
	if hash xdpyinfo 2>/dev/null; then
		displayResolution=$(xdpyinfo  | grep dimensions)
		printf "${bold}${green}OK${normal}\tDisplay $displayResolution\n"
	fi
}




# ---------------------------------------------------------------------
# Name:             checkRequirements
# Function:         Check the package requirements
#                   - imageMagick
#                   - cURL (for remote mode aka muzei mode)
#                   - jq (for remote mode aka muzei mode)
# Mode:             local & remote
# ---------------------------------------------------------------------
function checkRequirements()
{
    # ImageMagick - needed in general
    #
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

    # if configured to remote mode
    #
    if [ "$operationMode" = "2" ]; then
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
    newImage=$(find $localImageFolder -type f \( -name '*.jpg' -o -name '*.JPG' -o -name '*.jpeg' -o -name '*.JPEG' -o -name '*.png' -o -name '*.PNG' \) | shuf -n 1)

    if ! [ -f "$localImageFolder/$newImage" ]; then # check if random picked file exists

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

	case "$imageModificationMode" in

         # 0 = normal-mode
		0)  convert "$newImage" $blurCommand $dimCommand  $workInProgess     # Create a dimmed & blur-verion of the image into the working dir
			printf "${bold}${green}OK${normal}\tGenerated the new plain wallpaper in ${underline}$installationPath/$outputFilename${normal}\n"
    		;;

        # 1 = grayscale
		1)  convert "$newImage" $blurCommand $dimCommand $grayscaleCommand  $workInProgess     # Create a dimmed & blur-verion of the image into the working dir
   		    printf "${bold}${green}OK${normal}\tGenerated the new grayscaled wallpaper in ${underline}$installationPath/$outputFilename${normal}\n"
            ;;

        # 2 = sepia-mode
		2)  convert "$newImage" $blurCommand $dimCommand $sepiaCommand  $workInProgess     # Create a dimmed & blur-verion of the image into the working dir
			printf "${bold}${green}OK${normal}\tGenerated the new sepia wallpaper in ${underline}$installationPath/$outputFilename${normal}\n"
    		;;

        # 3 = colorize
   		3)  convert "$newImage" $blurCommand $dimCommand $colorizeCommand  $workInProgess     # Create a dimmed & blur-verion of the image into the working dir
   			printf "${bold}${green}OK${normal}\tGenerated the new colorized wallpaper in ${underline}$installationPath/$outputFilename${normal}\n"
       		;;

        # 4 = levelColors
        4)  convert "$newImage" $blurCommand $dimCommand $levelColorsCommand  $workInProgess     # Create a dimmed & blur-verion of the image into the working dir
            printf "${bold}${green}OK${normal}\tGenerated the new level-colors wallpaper in ${underline}$installationPath/$outputFilename${normal}\n"
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

    printf "${bold}${green}OK${normal}\tFinished image processing\n"
    return
}



# ---------------------------------------------------------------------
# Name:             setLinuxWallpaper
# Function:         Tries to set the new generated image as new wallpaper
# Mode:             local and remote
# ---------------------------------------------------------------------
function setLinuxWallpaper() {

    printf "${bold}${green}OK${normal}\tTrying to set the wallpaper ...\n"

    # gnome-settings-daemon
    if [ "$(pidof gnome-settings-daemon)" ]; then
        /usr/bin/gsettings set org.gnome.desktop.background picture-uri file://$installationPath/$1
        message="Wallpaper updated (using gsettings/gnome-settings-daemon)"
        displayNotification "$appName" "$message"
        logWallp "$message"
        printf "${bold}${green}OK${normal}\t$message\n"
        return
    fi

    # gconftool2
    if hash gconftool-2 2>/dev/null; then
        gconftool-2 --type=string --set /desktop/gnome/background/picture_filename $installationPath/$1
        displayNotification "$appName" "Wallpaper updated (using gconftool2)"
        message="Wallpaper updated (using gconftool2)"
        logWallp "$message"
        printf "${bold}${green}OK${normal}\t$message\n"
        return
    fi

    # feh
    if hash feh 2>/dev/null; then
        printf "${bold}${yellow}WARNING${normal}\tDetected feh (experimental)\n"
        feh --bg-max $installationPath/$1
        message="Wallpaper updated (using feh)"
        logWallp "$message"
        printf "${bold}${green}OK${normal}\t$message\n"
        return
    fi

    message="No supported desktop environment detected."
    logWallp "$message"

    printf "${bold}${red}ERROR${normal}\tSorry but $appName was most likely unable to set your wallpaper.\n"
    printf "${bold}${red}ERROR${normal}\tCurrently only gnome-settings-daemon, gconftool2 and feh are supported methods to set the walpaper\n"
    printf "${bold}${red}ERROR${normal}\tNone of them were detected on your system.\n"
    printf "${bold}${red}ERROR${normal}\tMore: ${underline}$appDocURL/Supported-Desktop-Environments${normal}. Exiting (errorcode 99).\n"
    exit 99
}




# ---------------------------------------------------------------------
# Name:             displayAppVersion
# Function:         Outputs the app version
# Mode:             local and remote
# ---------------------------------------------------------------------
function displayAppVersion()
{
    printf "\n${bold}Version:${normal}\n"
    printf "  $appVersion\n\n"
    printf "${bold}Documentation:${normal}\n"
    printf "  $appDocURL\n\n"
    exit 0 # exit with success-message
}



# ---------------------------------------------------------------------
# Name:             displayAppHelp
# Function:         Outputs the app help
# Mode:             local and remote
# ---------------------------------------------------------------------
function displayAppHelp()
{
    printf "\n${bold}Usage:${normal}\n"
    printf "  Mainscript:   ./updWallp.sh\n"
    printf "  Togglescript: ./updWallpShowOrg.sh\n\n"
    printf "  Help:         -h\n"
    printf "                --help\n\n"
    printf "  Version:      -v\n"
    printf "                --version\n\n"
    printf "${bold}Documentation:${normal}\n"
    printf "  $appDocURL\n\n"
    exit 0 # exit with success-message
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
