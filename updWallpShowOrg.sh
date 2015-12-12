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
                printf "${bold}${green}OK${normal}\tInstallation folder is set to: ${underline}$installationPath${normal}\n"
                checkOperatingSystem                         # check operating system
                setLinuxWallpaper "$backupFilename"        # set the linux wallpaper to the original file
                printf "${bold}${green}OK${normal}\tWaiting for $toggleTime (seconds) until toggling back\n"
                sleep "$toggleTime"
                setLinuxWallpaper "$outputFilename"        # set the linux wallpaper back to the dimmed/blured version
                exit 0 # exit with success
                ;;

            *)
                printf "$error04"
                exit 4
        esac

	else		# installationPath not configured
        printf "ERROR\tInvalid installationPath ($installationPath) in ${underline}config.sh${normal}. Exiting (errorcode 2)\n"
        exit 2
	fi
else
    printf "ERROR\tUnable to find 'config.sh'. Exiting (errorcode 1)\n"
	exit 1
fi
