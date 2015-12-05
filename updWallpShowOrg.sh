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
clear
currentPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -f $currentPath/config.sh ]; then # found config file
   source $currentPath/config.sh #load config file

	# if installationPath is configured in config.sh and valid
	if [ -d "$installationPath" ]; then
		cd $installationPath
      source inc/loader.sh # source loader.sh 
		startUp
		#check if the user did supply any paramter or not
		if [ -z "$primaryParameter" ];then
			# no parameter -> do the normal script logic
         printf "${bold}${green}OK${normal} ... updWallp folder is set to: ${underline}$installationPath${normal}\n"
			checkOperatingSystem                         # check operating system
			setLinuxWallpaper "$backupFilename"        # set the linux wallpaper to the original file
			printf "${bold}${green}OK${normal} ... Waiting for $toggleTime (seconds) until toggling back\n"
			sleep "$toggleTime"
			setLinuxWallpaper "$outputFilename"        # set the linux wallpaper back to the dimmed/blured version
			exit 0 # exit with success
		else # user supplied a parameter
			# check if parameter is valid: -h = help/documentation
			if [ "$primaryParameter" = "-h" ]; then
				printf "${bold}Usage:${normal}\n"
				printf "  ./updWallpShowOrg.sh\n\n"
				printf "${bold}Documentation:${normal}\n"
				printf "  $appDocURL\n"
				exit 0 # exit with success

         elif [ "$primaryParameter" = "-v" ] || [ "$primaryParameter" = "--version" ] ; then
            printf "\n${bold}Version:${normal}\n"
            printf "  $appVersion\n\n"
            printf "${bold}Documentation:${normal}\n"
            printf "  $appDocURL\n"
            exit 0 # exit with success-message
			else
				#printf "${bold}${red}ERROR${normal} Invalid parameter '$1'\n\nStart with: '-h' for some basic instructions.\n"
            printf "$error04"
				exit 4
			fi
		fi
	else		# installationPath not configured
      printf "$error02"
		exit 2
	fi
else
	printf "${bold}${red}ERROR${normal} Unable to find 'config.sh'. Aborting\n"
   #printf "$error01"
	exit 1
fi
