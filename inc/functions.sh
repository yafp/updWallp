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
# Name:         checkOperatingSystem
# Function:     Checks if script is executored on a linux system
# Mode:
# ---------------------------------------------------------------------
function checkOperatingSystem()
{
    if [[ $OSTYPE = *linux* ]]; then # we are on linux - so continue checking

        # try to detect desktop environment
        printf "\n${bold}Detecting desktop environment ...${normal}\n"
        linuxSession=$DESKTOP_SESSION
        if [[ $linuxSession == *"gnome"* ]]; then
            printfWallp "1" "Detected $linuxSession environment (tested)"
        else
            printfWallp "2" "Detected $linuxSession environment (experimental)"
        fi
        checkResolution # Check which desktop environment is in use

        validateConfig # valide the mission critical config values


    else # not linux -> not supported
        printfWallp "3" "Unexpected operating system: $OSTYPE. Exiting (errno 99)."
        exit 99
    fi
}



# ---------------------------------------------------------------------
# Name:         validateConfig
# Function:     Checks the content of config.sh
# Mode:         local and remote
# ---------------------------------------------------------------------
function validateConfig()
{
    printf "\n${bold}Config validation ...${normal}\n"

    # check operation mode
    #
    if [ -z "$operationMode" ]; then
        printfWallp "3" "Misconfigured operation mode (operationMode in config.sh is unset). Exiting (errno 99)."
        exit 99
    else
        if [ "$operationMode" = "1" ] || [ "$operationMode" = "2" ] ; then
            printfWallp "1" "Operation mode: $operationMode"
            if [ "$operationMode" = "1" ]; then
                if [ -z "$localImageFolder" ]; then
                    printfWallp "3" "Misconfigured local image folder (localImageFolder in config.sh is unset). Exiting (errno 99)."
                    exit 99
                else
                    if [ -d "$localImageFolder" ]; then
                        printfWallp "1" "Local image folder: $localImageFolder"
                    else
                        printfWallp "3" "Misconfigured local image folder (localImageFolder in config.sh is not valid). Exiting (errno 99)."
                        exit 99
                    fi
                fi
            fi
        else
            printfWallp "3" "Misconfigured operation mode (operationMode in config.sh). Exiting (errno 99)."
            exit 99
        fi
    fi

    # check modification mode
    if [ -z "$imageModificationMode" ]; then
        printfWallp "3" "Misconfigured modification mode (imageModificationMode in config.sh is unset). Exiting (errno 99)."
        exit 99
    else
        if [ "$imageModificationMode" = "0" ] || [ "$imageModificationMode" = "1" ] || [ "$imageModificationMode" = "2" ] || [ "$imageModificationMode" = "3" ] || [ "$imageModificationMode" = "4" ] ; then
            printfWallp "1" "Modification mode: $imageModificationMode"
        fi
    fi

    printfWallp "1" "Finished config validation. Everything looks fine."
    printf "\n${bold}Image handling ...${normal}\n"
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
        printfWallp "1" "Display$displayResolution"
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
        logWallp "Found ImageMagick (required)"
    else
        printfWallp "3" "ImageMagick not found. Exiting (errno 99)."
        exit 99
    fi

    # if configured to remote mode
    #
    if [ "$operationMode" = "2" ]; then
        if hash curl 2>/dev/null; then # check for curl
            logWallp "Found cURL (required for remote-mode)"
        else
            printfWallp "3" "cURL not found (required for remote-mode). Exiting (errno 99)."
            exit 99
        fi

        if hash jq 2>/dev/null; then # check for jq
            logWallp "Found JQ (required for remote-mode)"
        else
            printfWallp "3" "JQ not found (required for remote-mode). Exiting (errno 99)."
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
        $notifyPath "$1" "$2" -i "$projectPath/img/appIcon_128px.png"
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
        printfWallp "1" "Downloaded muzei.json (initial)."
    else
        curl -o muzeich2.json 'https://muzeiapi.appspot.com/featured?cachebust=1'
        printfWallp "1" "Downloaded muzei.json (checking for changes)."
        # there is a new muzei image available
        if [ "$(cmp muzeich.json muzeich2.json)" ]; then
            mv muzeich2.json muzeich.json
            printfWallp "1" "There is a new Muzei image available. Loading it."
        else # muzei offers still the same image
            rm muzeich2.json # remove the second json file
            printfWallp "1" "There is no new Muzei image available. Nothing to do here."
            exit
        fi
    fi

    # parse the Muzei JSON to extract the new image url
    imageUri=`jq '.imageUri' $projectPath/muzeich.json | sed s/\"//g`
    imageFile=`basename $imageUri`
    title=`jq '.title' $projectPath/muzeich.json | sed s/\"//g`
    byline=`jq '.byline' $projectPath/muzeich.json | sed s/\"//g`

    echo "File $imageFile does not exist, downloading..."
    curl -O $imageUri
    convert $imageFile $muzeiFilename
    newImage=$projectPath/$muzeiFilename

    printfWallp "1" "Finished getting latest Muzei image."
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
                printfWallp "2" "Random pick was in portrait-mode - repick"
                return
            fi
        fi

        printfWallp "1" "Random image: $newImage"
    else
        printfWallp "3" "Random file ($newImage) was not an image. Exiting (errno 88)."
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
    printf "${bold}${green}OK${normal}\tFinished mirroring source image to $projectPath/$backupFilename\n"

	case "$imageModificationMode" in

         # 0 = normal-mode
		0)  convert "$newImage" $blurCommand $dimCommand  $workInProgess     # Create a dimmed & blur-verion of the image into the working dir
            printfWallp "1" "Generated the new plain wallpaper in $projectPath/$outputFilename"
    		;;

        # 1 = grayscale
		1)  convert "$newImage" $blurCommand $dimCommand $grayscaleCommand  $workInProgess     # Create a dimmed & blur-verion of the image into the working dir
            printfWallp "1" "Generated the new grayscaled wallpaper in $projectPath/$outputFilename"
            ;;

        # 2 = sepia-mode
		2)  convert "$newImage" $blurCommand $dimCommand $sepiaCommand  $workInProgess     # Create a dimmed & blur-verion of the image into the working dir
            printfWallp "1" "Generated the new sepia wallpaper in $projectPath/$outputFilename"
    		;;

        # 3 = colorize
   		3)  convert "$newImage" $blurCommand $dimCommand $colorizeCommand  $workInProgess     # Create a dimmed & blur-verion of the image into the working dir
            printfWallp "1" "Generated the new colorized wallpaper in $projectPath/$outputFilename"
       		;;

        # 4 = levelColors
        4)  convert "$newImage" $blurCommand $dimCommand $levelColorsCommand  $workInProgess     # Create a dimmed & blur-verion of the image into the working dir
            printfWallp "1" "Generated the new level-colors wallpaper in $projectPath/$outputFilename"
            ;;

		*)  printfWallp "3" "Image modification mode is set to $imageModificationMode which isn't correct. Exiting (errno 99)"
			exit 99
   			;;
	esac

    # scale image to user-defined with if configured in config.sh
    if [ "$enableScaleToWidth" = true ]; then
        convert $workInProgess -thumbnail $imageWidth $workInProgess     # Create a dimmed & blur-verion of the image into the working dir
        printfWallp "1" "Scaled image to defined width of $imageWidth pixel."
    fi

    # Add Label if configured (testing)
    if [ "$addAppLabelOnGeneratedWallpaper" = true ] ; then
        composite -geometry  +0+1200 "img/appLabel_150x40px.png" $workInProgess $workInProgess
        printfWallp "1" "Added app-label to $projectPath/$outputFilename"
    fi

    # image creation is done - rename work-in-progress-file to final filename for new wallpaper
    # this avoids sideeffects / racing conditions if we write several time to the filename which is in use at the same time
    # -> avoids flickering while script-execution
    convert $workInProgess $outputFilename

    printfWallp "1" "Finished image processing"
    return
}



# ---------------------------------------------------------------------
# Name:             setLinuxWallpaper
# Function:         Tries to set the new generated image as new wallpaper
# Mode:             local and remote
# ---------------------------------------------------------------------
function setLinuxWallpaper() {

    printf "\n${bold}Updating wallpaper ...${normal}\n"

    # gnome-settings-daemon
    if [ "$(pidof gnome-settings-daemon)" ]; then
        /usr/bin/gsettings set org.gnome.desktop.background picture-uri file://$projectPath/$1
        message="Wallpaper updated (using gsettings/gnome-settings-daemon)"
        displayNotification "$appName" "$message"
        printfWallp "1" "$message"
        return
    fi

    # gconftool2
    if hash gconftool-2 2>/dev/null; then
        gconftool-2 --type=string --set /desktop/gnome/background/picture_filename $projectPath/$1
        message="Wallpaper updated (using gconftool2)"
        displayNotification "$appName" "$message"
        printfWallp "1" "$message"
        return
    fi

    # feh
    if hash feh 2>/dev/null; then
        feh --bg-max $projectPath/$1
        message="Trying to set wallpaper (using feh - experimental)"
        displayNotification "$appName" "$message"
        printfWallp "2" "$message"
        return
    fi

    printfWallp "3" "Found no method to update wallpaper"
    printfWallp "3" "Currently only gnome-settings-daemon, gconftool2 and feh (experimental) are supported methods to set the walpaper"
    printfWallp "3" "More: $appDocURL/Supported-Desktop-Environments. Exiting (errno 99)."
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
        printf "$timestamp\t\t$1\n" >> "$projectPath/logs/updWallpLog.txt"
        return
        ;;

      *)
        printf "${bold}${yellow}WARNING${normal}\tYou have misconfigured loggingMode in config.sh with an value of: $loggingMode.\n"
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
    printf "$messageText\n"


    # now trigger logging with the messageText
    logWallp "$messageText"
}



# ---------------------------------------------------------------------
# Name:             cleanupUpdWallpDir
# Function:         Clean the app folder at the end of the processing
# ---------------------------------------------------------------------
function cleanupUpdWallpDir()
{
    printf "\n${bold}Post-processing ...${normal}\n"

    if [ -f "$imageFile" ]; then
        rm $imageFile # from remote mode: org muzei name with org name
    fi

    if [ -f "$workInProgess" ];then
        rm $workInProgess
    fi

    printfWallp "1" "Finished cleaning up $projectPath\n\n"
}
