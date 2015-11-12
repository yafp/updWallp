#!/bin/bash
#
#  Name:    updWallp
#  Github:
#
#  Related: https://github.com/aepirli/linmuzei


# ---------------------------------------------------------------------
# CONFIGURATION
# ---------------------------------------------------------------------
imageSourcePath="/home/fidel/Dropbox/Photos/WallpaperTest/"

baseFile="/home/fidel/Desktop/currentBaseWallpaper.png"
generatedFile="currentGeneratedWallpaper1.png"



# ---------------------------------------------------------------------
# REQUIREMENTS
# ---------------------------------------------------------------------
# - Imagemagick:
command -v convert >/dev/null 2>&1 || { echo >&2 "Imagemagick is required but not installed.  Aborting."; exit 1; }


# ---------------------------------------------------------------------
# GENERATE CURRENT IMAGES IN WORKING DIR
# ---------------------------------------------------------------------
# pick random image from source folder
randomImage=$(find $imageSourcePath -type f | shuf -n 1)

# copy random base image to project folder
convert "$randomImage"  $baseFile

# Create a dimmed & blur-verion of the image into the working dir
#
#convert "$randomImage" -channel RGBA  -blur 0x8  $targetFile #blur
#convert "$randomImage" -brightness-contrast -30x10 $targetFile2 #dim - where -30 is to darken by 30 and +10 is to increase the contrast by 10.
convert "$randomImage" -channel RGBA  -blur 0x8 -brightness-contrast -30x10  $generatedFile



# ---------------------------------------------------------------------
# NOTIFICATION
# ---------------------------------------------------------------------
notify-send "Generated new wallpaper" -i "~/Desktop/logo.png"
