#!/bin/bash
#
#  Name:			updWallpShowOrg.sh
#  Function:	Script to temporary toggle back to the original image for a defined time
#  Usage:		./updWallpShowOrg.sh
#					./updWallpShowOrg.sh -h
#
#  Github:		https://github.com/yafp/updWallp
#


# ---------------------------------------------------------------------
# LOCAL CONFIG
# ---------------------------------------------------------------------
updWallpDir=""        # define the folder where you copied the updWallp folder to
toggleTime=10s                                  # how long the original image is displayed if user manually toggles script: updWallpShowOrg.sh


# #####################################################################
# SCRIPT-LOGIC
# #####################################################################
clear

if [ -d "$updWallpDir" ] # if updWallpDir is configured and valid
	then
	cd $updWallpDir

	source inc/loader.sh 	# load all inc files

	printf "${bold}${green}OK${normal} ... updWallp folder is set to: ${underline}$updWallpDir${normal}\n"
	startUp
	if [ -z "$1" ];	# if user did not supply any paramter
		then # do the normal script logic
			checkOperatingSystem                         # check operating system
			setLinuxWallpaper "$backupFilename"        # set the linux wallpaper to the original file
			printf "${bold}${green}OK${normal} ... Waiting for $toggleTime (seconds) until toggling back\n"
			sleep "$toggleTime"
			setLinuxWallpaper "$outputFilename"        # set the linux wallpaper back to the dimmed/blured version

	else # user supplied a parameter
		if [ "$1" = "-h" ] # check if parameter is valid: -h = help/documentation
			then
				printf "${bold}Usage:${normal}\n"
				printf "  ./updWallpShowOrg.sh\n\n"
				printf "${bold}Documentation:${normal}\n"
				printf "  https://github.com/yafp/updWallp/wiki\n"
		else
			printf "${bold}${red}ERROR${normal} Invalid parameter '$1'\n\nStart with: '-h' for some basic instructions.\n"
		fi
	fi
else		# updWallpDir is not configured
	printf "${bold}${red}ERROR${normal} Variable 'updWallpDir' is not not configured or not valid. Aborting\n"
	exit # die
fi
