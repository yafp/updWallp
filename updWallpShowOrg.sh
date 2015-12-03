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
toggleTime=10s                                  # how long the original image is displayed if user manually toggles script: updWallpShowOrg.sh


# #####################################################################
# SCRIPT-LOGIC
# #####################################################################
currentPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -f $currentPath/config.sh ]; then # found config file
   source $currentPath/config.sh #load config file
	# if installationPath is configured in config.sh and valid
	if [ -d "$installationPath" ]; then
		cd $installationPath
		source inc/loader.sh 	# source the loader for all other inc files
		printf "${bold}${green}OK${normal} ... updWallp folder is set to: ${underline}$installationPath${normal}\n"
		startUp
		#check if the user did supply any paramter or not
		if [ -z "$1" ];then
			# no parameter -> do the normal script logic
			checkOperatingSystem                         # check operating system
			setLinuxWallpaper "$backupFilename"        # set the linux wallpaper to the original file
			printf "${bold}${green}OK${normal} ... Waiting for $toggleTime (seconds) until toggling back\n"
			sleep "$toggleTime"
			setLinuxWallpaper "$outputFilename"        # set the linux wallpaper back to the dimmed/blured version
			exit
		else # user supplied a parameter
			# check if parameter is valid: -h = help/documentation
			if [ "$1" = "-h" ]; then
				printf "${bold}Usage:${normal}\n"
				printf "  ./updWallpShowOrg.sh\n\n"
				printf "${bold}Documentation:${normal}\n"
				printf "  https://github.com/yafp/updWallp/wiki\n"
				exit
			else
				printf "${bold}${red}ERROR${normal} Invalid parameter '$1'\n\nStart with: '-h' for some basic instructions.\n"
				exit
			fi
		fi
	else		# updWallpDir is not configured
		printf "${bold}${red}ERROR${normal} Variable 'installationPath' is not configured (in config.sh) or not valid. Aborting\n"
		exit # die
	fi
else
	printf "${bold}${red}ERROR${normal} Unable to find 'config.sh'. Aborting\n"
	exit
fi
