#!/bin/bash
#
#  Name:       updWallp.sh
#  Function:   Script to pick a random image from a folder, generate a dimmed & blured version of it and set it as wallpaper
#  Usage:
#					local mode: 			./updWallp.sh -l /path/to/yourImageSourceFolder
#					remote mode: 			./updWallp.sh -r
#					help:						./updWallp.sh -h
#
#  Github:     https://github.com/yafp/updWallp
#


# ---------------------------------------------------------------------
# LOCAL CONFIG
# ---------------------------------------------------------------------
updWallpDir=""              # define the folder where you copied the updWallp folder to (Example: /home/username/updWallp)

muzeiFilename="muzeiImage.png"
primaryParamter=$1
localUserImageFolder=$2




# #####################################################################
# SCRIPT-LOGIC
# #####################################################################
clear
if [ -d "$updWallpDir" ]; # updWallp directory is set and valid
	then
	cd $updWallpDir # change to defined folder

	source config.sh # load the config file
	source functions.sh # load functions

	startUp
	printf "${bold}${green}OK${normal} ... updWallp folder is set to: $updWallpDir\n"

	# Check if user supplied a parameter $1 to set a mode
	#
	if [ -z "$primaryParamter" ]; # user did not supply $1
		then
			printf "${bold}${red}ERROR${normal} ... you didnt supply any parameter. Try -h to get instructions\n"
			exit
	else # user supplied at least $1

		# Parameter was: -h
		if [ "$primaryParamter" = "-h" ]; # parameter was -h
			then
				printf "\n${bold}Usage:${normal}\n"
				printf "  Help:         ./updWallp.sh -h\n"
				printf "  Local-Mode:   ./updWallp.sh -l /path/to/local/image/folder\n"
				printf "  Remote-Mode:  ./updWallp.sh -r\n\n"
				printf "${bold}Documentation:${normal}\n"
				printf "  https://github.com/yafp/updWallp/wiki\n"
				exit
		fi

		# Parameter was: -l aka Local-Mode
		if [ "$primaryParamter" = "-l" ]; # parameter was -h
			then
				checkOperatingSystem                         # check operating system
				checkImageMagick                             # function to check if ImageMagick is installed
				printf "${bold}${green}OK${normal} ... Local-mode\n"
				checkImageSourceFolder

				# Core work
				generateNewWallpaper                         # generates a new wallpaper
				setLinuxWallpaper  "$outputFilename"         # set the linux wallpaper

				# Post work
				cleanupUpdWallpDir                           # Cleaning up
				exit
		fi


		# Parameter was: -lr aka Remote-Mode
		if [ "$primaryParamter" = "-r" ]; # parameter was -r
			then
				checkOperatingSystem                         # check operating system
				checkImageMagick                             # function to check if ImageMagick is installed

				printf "${bold}${green}OK${normal} ... Remote-mode (Muzei)\n"
				checkRemoteRequirements
				getRemoteMuzeiImage

				# Core work
				generateNewWallpaper                         # generates a new wallpaper
				setLinuxWallpaper  "$outputFilename"         # set the linux wallpaper

				# Post work
				cleanupUpdWallpDir                           # Cleaning up
				exit
		else # wrong parameter
			printf "${bold}${red}ERROR${normal} Invalid parameter '$primaryParamter'\n\nStart with: '-h' for some basic instructions.\n"
			exit
		fi

	fi
else
	printf "${bold}${red}ERROR${normal} updWallp folder not configured or not valid.\n"
	exit                                                              # otherwise die
fi
