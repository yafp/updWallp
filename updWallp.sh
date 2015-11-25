#!/bin/bash
#
#  Name:       updWallp.sh
#  Function:   Script to pick a random image from a folder, generate a dimmed & blured version of it and set it as wallpaper
#  Usage:
#					local mode: 			./updWallp.sh -l /path/to/yourImageSourceFolder
#					remote mode: 			./updWallp.sh -r
#  Github:     https://github.com/yafp/updWallp
#


# ---------------------------------------------------------------------
# LOCAL CONFIG
# ---------------------------------------------------------------------
updWallpDir=""              # define the folder where you copied the updWallp folder to (Example: /home/username/updWallp)
muzeiFilename="muzeiImage.png"
primaryParamter=$1
imageSourcePath=$2






# #####################################################################
# SCRIPT-LOGIC
# #####################################################################
clear
if [ -d "$updWallpDir" ]; # updWallp directory is set and valid
	then
	cd $updWallpDir

	source config.sh
	source functions.sh

	startUp
	printf "${bold}${green}OK${normal} ... updWallp folder is set to: $updWallpDir\n"

	# Check supplied paramters
	if [ -z "$primaryParamter" ]; # user did not supply $1
		then
			printf "ERROR - you didnt supply any paramter. Try -h to get instructions\n"
			exit
	else # user supplied $1   	

		# Parameter was: -h
		if [ "$1" = "-h" ]; # parameter was -h
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
		if [ "$1" = "-l" ]; # parameter was -h
			then
				checkOperatingSystem                         # check operating system
				checkImageMagick                             # function to check if ImageMagick is installed
				
				#checkLocalOrRemoteMode                       # check if script runs in local or remote (muzei) mode
				printf "${bold}${green}OK${normal} ... Local Mode\n"
				checkImageSourceFolder
				
				# Core work
				generateNewWallpaper                         # generates a new wallpaper
				setLinuxWallpaper  "$outputFilename"         # set the linux wallpaper

				# Post work
				cleanupUpdWallpDir                           # Cleaning up
				exit
		fi
		
		
		
		# Parameter was: -lr aka Remote-Mode
		if [ "$1" = "-r" ]; # parameter was -r
			then
				checkOperatingSystem                         # check operating system
				checkImageMagick                             # function to check if ImageMagick is installed
				
				printf "${bold}${green}OK${normal} ... Remote Mode (Muzei Mode)\n"
				checkRemoteRequirements
				getRemoteMuzeiImage
				
				# Core work
				generateNewWallpaper                         # generates a new wallpaper
				setLinuxWallpaper  "$outputFilename"         # set the linux wallpaper

				# Post work
				cleanupUpdWallpDir                           # Cleaning up
				exit
		fi
		
	fi
else
	printf "${bold}${red}ERROR:${normal} updWallp folder not configured or not valid. Aborting\n"
	exit                                                              # otherwise die
fi
