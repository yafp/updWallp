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
localUserImageFolder=$2



# #####################################################################
# SCRIPT-LOGIC
# #####################################################################
clear
currentPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -f $currentPath/config.sh ]; then # found config file
	source $currentPath/config.sh # load config file

	# check if installationPath directory is set and valid (in config.sh)
	if [ -d "$installationPath" ]; then
		cd $installationPath # change to defined folder
		source inc/loader.sh # source loader.sh
		startUp

		# NEW
		#
		case "$primaryParameter" in
			"-h")
				displayAppHelp
    			;;

			"--help")
				displayAppHelp
				;;

			"-v")
				displayAppVersion
	    		;;

			"--version")
				displayAppVersion
				;;

			"")
				# seems like script should do some actual work .... check operationMode
				checkOperatingSystem                         # check operating system
				checkImageMagick                             # function to check if ImageMagick is installed

				if [ "$operationMode" = "1" ] || [ "$operationMode" = "2" ] ; then # if operationMode is valid

					# if configured to local mode
					if [ "$operationMode" = "1" ]; then
						printf "${bold}${green}OK${normal}\tUsing local-mode (-l)\n"
						checkImageSourceFolder
					fi

					# if configured to remote mode
					if [ "$operationMode" = "2" ]; then
						printf "${bold}${green}OK${normal}\tUsing remote-mode (-r)\n"
						checkRemoteRequirements
						getRemoteMuzeiImage
					fi

					generateNewWallpaper                         # generates a new wallpaper
					setLinuxWallpaper  "$outputFilename"         # set the linux wallpaper
					cleanupUpdWallpDir                           # Cleaning up
					exit 0 										# exit with success-message

				else
					printf "${bold}${red}ERROR${normal}\tInvalid operationMode ($operationMode) in ${underline}config.sh${normal}. Check config.sh.\n"
					exit 99
				fi # check if operationMode is valid or not
				;;

			*)
				printf "$error04"
				exit 4
		esac

	else # = updWallp directory is not set or not valid
		printf "ERROR\tInvalid installationPath ($installationPath) in ${underline}config.sh${normal}. Exiting (errorcode 2)\n"
		exit 2 # die
	fi # end of checking updWallp directory
else # unable to load config.sh
	printf "ERROR\tUnable to find 'config.sh'. Exiting (errorcode 1)\n"
	exit 1
fi
