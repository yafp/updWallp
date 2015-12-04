#!/bin/bash
#
#  Name:       config.sh
#  Function:   Acts as central configuration file for the updWallp scripts
#  Github:     https://github.com/yafp/updWallp
#

# ---------------------------------------------------------------------
# DECLARE VARIABLES
# ---------------------------------------------------------------------
#declare installationPath      # Type: string       Function: holds the installation-path of the project folder



# ---------------------------------------------------------------------
# 0. INSTALLATIONPATH
#     example: $installationPath="/home/username/updWallp"
# ---------------------------------------------------------------------
installationPath="/home/fidel/Apps/updWallp"



# ---------------------------------------------------------------------
# 1. IMAGEMAGICK RELATED
#     blurCommand & dimCommand are used in all modes
# ---------------------------------------------------------------------
# blur  {radius}x{sigma}
# The important setting in the above is the second sigma value.
# It can be thought of as an approximation of just how much your want the image to 'spread' or blur, in pixels.
# Think of it as the size of the brush used to blur the image.
# The numbers are floating point values, so you can use a very small value like '0.5'.
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



# ---------------------------------------------------------------------
# 2. IMAGE-MODIFICATIONS-MODES
#	0	= normal
#	1	= grayscale
#	2	= sepia
# ---------------------------------------------------------------------
imageModificationMode="1"

# Grayscale command
grayscaleCommand="-type Grayscale"

# Sepia command
sepiaCommand="-sepia-tone 90%"



# ---------------------------------------------------------------------
# 3. ADD-LABEL-TO-WALLPAPER
# ---------------------------------------------------------------------
addAppLabelOnGeneratedWallpaper=false 	# true or false




# ---------------------------------------------------------------------
# 4. NOTIFICATION RELATED
# ---------------------------------------------------------------------
enableNotifications=false                             # true or false
notifyPath="/usr/bin/notify-send"                     # defines the path to notify-send which is used to display desktop notifications



# undocumented
primaryParameter=$1
