#!/bin/bash
#
#  Name:       config.sh
#  Function:   Acts as central configuration file for the updWallp scripts
#  Github:     https://github.com/yafp/updWallp
#

# ---------------------------------------------------------------------
# CONFIGURATION
# ---------------------------------------------------------------------


# ---------------------------------------------------------------------
# IMAGEMAGICK RELATED
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


# Special-Mode: Grayscale
enableGrayscaleMode=true                            # true or false. If true - images get converted to grayscale (black & white)
grayscaleCommand="-type Grayscale"
# or
#
# Special-Mode: Sepia
enableSepiaMode=false                                 # true or false.
sepiaCommand="-sepia-tone 90%"



# ---------------------------------------------------------------------
# NOTIFICATION RELATED
# ---------------------------------------------------------------------
enableNotifications=false                             # true or false
notifyPath="/usr/bin/notify-send"                     # defines the path to notify-send which is used to display desktop notifications



# ---------------------------------------------------------------------
# FILENAMES for ImageCreation
# ---------------------------------------------------------------------
backupFilename="currentBaseWallpaper.png"             # filename for backup copy of selected file
outputFilename="currentGeneratedWallpaper.png"        # generated Wallpaper which is set as wallpaper
