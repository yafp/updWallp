#!/bin/bash
#
#  Name:       config.sh
#  Function:   Acts as central configuration file for the updWallp scripts
#  Github:     https://github.com/yafp/updWallp
#



# ---------------------------------------------------------------------
# 0. DEBUGGING OUTPUT
#       To enable bash debug enable the following: set -x
# ---------------------------------------------------------------------
#set -x


# ---------------------------------------------------------------------
# 1. INSTALLATIONPATH (mission-critical)
#       example: installationPath="/home/username/updWallp"
# ---------------------------------------------------------------------
installationPath="/home/fidel/Apps/updWallp"



# ---------------------------------------------------------------------
# 2. OPERATION-MIDE
#       1 = local mode
#       2 = remote mode (muzei)
#
#       example:    operationMode="1"
# ---------------------------------------------------------------------
operationMode="1"

# localImageFolder defines the path to the local image source
# must be defined for local-mode
localImageFolder="/media/mnt_raid1_3000/MEDIA/Pictures/Pics_For_TV/All_Images/"



# ---------------------------------------------------------------------
# 3. IMAGEMAGICK RELATED
#       images get blured and dimmed - thats the core-function of this project
#       feel free to modify the blur and dim commands
#       empty commands result in no change to the image ;)
#       blurCommand & dimCommand are used in all modes (see 4.)
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
# Example:
#       -brightness-contrast -30x10
#       where -30 is to darken by 30 and +10 is to increase the contrast by 10.
dimCommand="-brightness-contrast -10x5"



# ---------------------------------------------------------------------
# 4. IMAGE-MODIFICATIONS-MODES
#       0 = normal (no changes)
#       1 = grayscale
#       2 = sepia
#       3 = colorize
#       4 = level-colors
# ---------------------------------------------------------------------
imageModificationMode="1"                       # must be set
#
grayscaleCommand="-type Grayscale"              # Grayscale command
sepiaCommand="-sepia-tone 90%"                  # Sepia command
colorizeCommand="-fill white -colorize 50%"     # colorize
levelColorsCommand="+level-colors Black,LightGreen"  # level-colors: 1 or 2 colors
#       example:    Navy,
#       or:         Navy, DarkGreen
#
# other ideas:                                  http://www.imagemagick.org/Usage/color_mods/
#
#  Sigmoidal Non-linearity Contrast
#     cmd="-sigmoidal-contrast 10,50%"  # colorize:




# ---------------------------------------------------------------------
# 5. RESIZE/SCALE TO WIDTH (OPTIONAL)
#       if enabled updWallp scales the created image down to the user-defined with
# ---------------------------------------------------------------------
enableScaleToWidth=true
imageWidth="1920" # px width for output




# ---------------------------------------------------------------------
# 6. PORTRAIT VS LANDSCAPE (OPTIONAL)
#       if enabled (true) updWallp tries to use only landscape images from the user-supplied folder in local-mode
# ---------------------------------------------------------------------
useOnlyLandscapeImages=true # true or false




# ---------------------------------------------------------------------
# 7. ADD-LABEL-TO-WALLPAPER (OPTIONAL)
#       if enabled - adds a 'created-with-updwallp-label to the image
# ---------------------------------------------------------------------
addAppLabelOnGeneratedWallpaper=false 	# true or false




# ---------------------------------------------------------------------
# 8. NOTIFICATION RELATED
#       if enabled - updWallp will display desktop notifications using notify-send
#       annoying if updWallp.sh is used in short cycles
# ---------------------------------------------------------------------
enableNotifications=true                            # true or false
notifyPath="/usr/bin/notify-send"                    # defines the path to notify-send which is used to display desktop notifications




# ---------------------------------------------------------------------
# 9. LOGGING MODE (logging is only used in updWallp.sh)
#       0 = no logging (default)
#       1 = syslog
#       2 = individual log in project folder
#
#       Example: loggingMode=1
# ---------------------------------------------------------------------
loggingMode=2
