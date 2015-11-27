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

	source inc/loader.sh 		# source all needed files

	startUp

	# Check if user supplied a parameter $1 to set a mode
	#
	if [ -z "$primaryParamter" ]; # user did not supply $1
		then
			printf "${bold}${red}ERROR${normal} ... you didnt supply any parameter. Try -h to get instructions\n"
			exit
	else # user supplied at least $1

		if [ "$primaryParamter" = "-h" ] || [ "$primaryParamter" = "-l" ] || [ "$primaryParamter" = "-r" ] ; # valid parameters
			then

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

			# for both: local and remote
			checkOperatingSystem                         # check operating system
			printf "${bold}${green}OK${normal} ... updWallp folder is set to: ${underline}$updWallpDir${normal}\n"
			checkImageMagick                             # function to check if ImageMagick is installed

			if [ "$primaryParamter" = "-l" ]; # parameter was -l = local mode
				then
					printf "${bold}${green}OK${normal} ... Using local-mode (-l)\n"
					checkImageSourceFolder
			fi

			if [ "$primaryParamter" = "-r" ]; # parameter was -r = remote mode
				then
					printf "${bold}${green}OK${normal} ... Using remote-mode (-r)\n"
					checkRemoteRequirements
					getRemoteMuzeiImage
			fi

			generateNewWallpaper                         # generates a new wallpaper
			setLinuxWallpaper  "$outputFilename"         # set the linux wallpaper
			cleanupUpdWallpDir                           # Cleaning up
			exit

		else # parameter was not valid
				printf "${bold}${red}ERROR${normal} Invalid parameter '$primaryParamter'\n\nStart with: '-h' for some basic instructions.\n"
				exit
		fi
	fi
else # = updWallp directory is not set or not valid
	printf "${bold}${red}ERROR${normal} updWallp folder not configured or not valid.\n"
	exit                                                              # otherwise die
fi # end of checking updWallp directory
