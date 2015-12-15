#!/usr/bin/env bash
#
#  Name:       updWallp.sh
#  Function:   Script to pick a random image from a folder, generate a dimmed & blured version of it and set it as wallpaper
#  Usage:
#					help:						./updWallp.sh -h
#					version:					./updWallp.sh -v
#					core function:				./updWallp.sh
#
#  Github:     https://github.com/yafp/updWallp
#


# ---------------------------------------------------------------------
# LOCAL CONFIG - no need to touch
# ---------------------------------------------------------------------




# #####################################################################
# SCRIPT-LOGIC
# #####################################################################
clear
projectPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -f $projectPath/config.sh ]; then # found config file
	source $projectPath/config.sh # load config file
	cd $projectPath # change to project folder
	source inc/loader.sh # source loader.sh (all other inc files are sources in loader.sh)
	startUp

	case "$primaryParameter" in
		"-h" | "--help")
			displayAppHelp
    		;;

		"-v" | "--version")
			displayAppVersion
	    	;;

		"")
			checkOperatingSystem    	# check operating system
			checkRequirements           # function to check for all required packages

			# if configured to local mode
			if [ "$operationMode" = "1" ]; then
				getNewRandomLocalFilePath
			fi

			# if configured to remote mode
			if [ "$operationMode" = "2" ]; then
				getRemoteMuzeiImage
			fi

			generateNewWallpaper                         # generates a new wallpaper
			setLinuxWallpaper  "$outputFilename"         # set the linux wallpaper
			cleanupUpdWallpDir                           # Cleaning up
			exit 0 										# exit with success-message
			;;

		*)
			printf "$error04"
			exit 4
			;;
	esac

else # unable to load config.sh
	printf "ERROR\tUnable to load 'config.sh'. Exiting (errno 1)\n"
	exit 1
fi
