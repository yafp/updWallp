#!/bin/bash
#
#  Name:       config-sh
#  Function:   Acts as central configuration file for the updWallp scripts
#  Github:     https://github.com/yafp/updWallp
#

# ---------------------------------------------------------------------
# CONFIGURATION
# ---------------------------------------------------------------------
updWallpDir=""               # Define where the updWallp folder is located- Must be configured

backupFilename="currentBaseWallpaper.png"             # filename for backup copy of selected file
outputFilename="currentGeneratedWallpaper.png"


# Text formatting for printf/echo
#
bold=$(tput bold)                                     # cli output in bold
normal=$(tput sgr0)                                   # cli output in normal


# image effects
#
blurCommand="-channel RGBA  -blur 0x9"                # imageMagick blur command example:    -channel RGBA  -blur 0x8
dimCommand="-brightness-contrast -30x10"              # imageMagick dim command example:     -brightness-contrast -30x10
                                                      #   where -30 is to darken by 30 and +10 is to increase the contrast by 10.

# notification-related
#
notifyPath="/usr/bin/notify-send"


# Time value for updWallShowOrg.sh
#
toggleTime=5s                                         # how long the original image is displayed if user manually toggles script: updWallpShowOrg.sh
