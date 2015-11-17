#!/bin/bash
#
#  Name:       config.sh
#  Function:   Acts as central configuration file for the updWallp scripts
#  Github:     https://github.com/yafp/updWallp
#

# ---------------------------------------------------------------------
# CONFIGURATION
# ---------------------------------------------------------------------

# Blur
#
#    -blur  {radius}x{sigma} 
# The important setting in the above is the second sigma value. It can be thought of as an approximation of just how much your want the image to 'spread' or blur, 
# in pixels. Think of it as the size of the brush used to blur the image. The numbers are floating point values, so you can use a very small value like '0.5'.
#
# The first value radius, is also important as it controls how big an area the operator should look at when spreading pixels. 
# This value should typically be either '0' or at a minimum double that of the sigma. 
#
# Example: -channel RGBA  -blur 0x8
blurCommand="-channel RGBA  -blur 0x16"



# Dim 
# 
# Example:  -brightness-contrast -30x10
#               where -30 is to darken by 30 and +10 is to increase the contrast by 10.
dimCommand=""




enableBlackWhiteMode=false                            # true or false. If true - images get converted to black & white
enableSepiaMode=false                                 # true or false.





# Filenames for generated and backup of source image
#
backupFilename="currentBaseWallpaper.png"             # filename for backup copy of selected file
outputFilename="currentGeneratedWallpaper.png"


# Text formatting for printf/echo
#
bold=$(tput bold)                                     # cli output in bold
normal=$(tput sgr0)                                   # cli output in normal



# Notification-related
notifyPath="/usr/bin/notify-send"



# Time value for updWallShowOrg.sh
toggleTime=5s                                         # how long the original image is displayed if user manually toggles script: updWallpShowOrg.sh



# ---------------------------------------------------------------------
# DONT TOUCH
# ---------------------------------------------------------------------
# AppVersion
appVersion=0.6
