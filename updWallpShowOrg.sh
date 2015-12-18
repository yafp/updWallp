#!/usr/bin/env bash
#
#  Name:		updWallpShowOrg.sh
#  Function:	Script to temporary toggle back to the original image for a defined time
#  Usage:		./updWallpShowOrg.sh
#				./updWallpShowOrg.sh -h
#               ./updWallpShowOrg.sh -v
#
#  Github:		https://github.com/yafp/updWallp
#


# ---------------------------------------------------------------------
# LOCAL CONFIG
# ---------------------------------------------------------------------
#set -o nounset              # outputs warning if unset variables are detected
toggleTime=10s              # how long the original image is displayed if user manually toggles script: updWallpShowOrg.sh


# #####################################################################
# SCRIPT-LOGIC
# #####################################################################
clear
projectPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -f $projectPath/config.sh ]; then # found config file
    source $projectPath/config.sh #load config file
    cd $projectPath
    source inc/loader.sh # source loader.sh
	startUp

    if [ "$#" -lt "1" ]; then # if max 1 parameter was commited to the script - it might be a valid input
        case "$primaryParameter" in
            "-h" | "--help")
                displayAppHelp
                ;;

            "-v" | "--version")
                displayAppVersion
                ;;

            "")
                checkOperatingSystem                       # check operating system
                setLinuxWallpaper "$backupFilename"        # set the linux wallpaper to the original file

                printf "\n${bold}Wating ...${normal}\n"
                printf "${bold}${green}OK${normal}\tWaiting for $toggleTime (seconds) until toggling back\n"
                sleep "$toggleTime"

                setLinuxWallpaper "$outputFilename"        # set the linux wallpaper back to the dimmed/blured version
                exit 0 # exit with success
                ;;

            *)
                printf "$error03"
                exit 3
        esac

    else # > 1 parameter
        printf "$error02"
		exit 2
    fi
else
    printf "ERROR\tUnable to load 'config.sh'. Exiting (errno 1)\n"
	exit 1
fi
