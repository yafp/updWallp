#!/bin/bash
#
#  Name:       updWallp.sh
#  Function:   Script to pick a random image from a folder, generate a dimmed & blured version of it and set it as wallpaper
#  Usage:
#					help:						./updWallp.sh -h
#					version:					./updWallp.sh -v
#					local mode: 			./updWallp.sh -l /path/to/yourImageSourceFolder
#					remote mode: 			./updWallp.sh -r
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

		# Check if user supplied a parameter $1 to set a mode
		if [ -z "$primaryParameter" ]; then
			# user did not supply $1
			printf "$error03"
			exit 3
		else # user supplied at least $1

			# valid parameters
			if [ "$primaryParameter" = "-h" ] || [ "$primaryParameter" = "-l" ] || [ "$primaryParameter" = "-r" ] || [ "$primaryParameter" = "-v" ] || [ "$primaryParameter" = "--version" ]; then

				# parameter was -h
				if [ "$primaryParameter" = "-h" ]; then
						printf "\n${bold}Usage:${normal}\n"
						printf "  Help:         ./updWallp.sh -h\n"
						printf "  Version:      ./updWallp.sh -v\n"
						printf "  Local-mode:   ./updWallp.sh -l /path/to/local/image/folder\n"
						printf "  Remote-mode:  ./updWallp.sh -r\n\n"
						printf "${bold}Documentation:${normal}\n"
						printf "  $appDocURL\n"
						exit 0 # exit with success-message
				fi

				# parameter was -v or --version
				if [ "$primaryParameter" = "-v" ] || [ "$primaryParameter" = "--version" ]; then
						printf "\n${bold}Version:${normal}\n"
						printf "  $appVersion\n\n"
						printf "${bold}Documentation:${normal}\n"
						printf "  $appDocURL\n"
						exit 0 # exit with success-message
				fi

				# for both: local and remote
				checkOperatingSystem                         # check operating system
				printf "${bold}${green}OK${normal} ... Installation folder is set to: ${underline}$installationPath${normal}\n"
				checkImageMagick                             # function to check if ImageMagick is installed

				# parameter was -l = local mode
				if [ "$primaryParameter" = "-l" ]; then
					printf "${bold}${green}OK${normal} ... Using local-mode (-l)\n"
					checkImageSourceFolder
				fi

				# parameter was -r = remote mode
				if [ "$primaryParameter" = "-r" ]; then
					printf "${bold}${green}OK${normal} ... Using remote-mode (-r)\n"
					checkRemoteRequirements
					getRemoteMuzeiImage
				fi

				generateNewWallpaper                         # generates a new wallpaper
				setLinuxWallpaper  "$outputFilename"         # set the linux wallpaper
				cleanupUpdWallpDir                           # Cleaning up
				exit 0 													# exit with success-message

			else # parameter was not valid
					printf "$error04"
					exit 4
			fi
		fi
	else # = updWallp directory is not set or not valid
		printf "$error02"
		exit 2 # die
	fi # end of checking updWallp directory
else # unable to load config.sh
	printf "${bold}${red}ERROR${normal} Unable to find 'config.sh'. Exiting (errorcode 1)\n"
	#printf "$error1"
	exit 1
fi
