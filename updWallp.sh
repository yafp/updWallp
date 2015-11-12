#!/bin/bash
#
#  Name:       updWallp
#  Function:   Script to pick a random image from a folder, generate a dimmed & blured version of it and set it as wallpaper
#  Github:     https://github.com/yafp/updWallp
#
#  Related:    https://github.com/aepirli/linmuzei


# ---------------------------------------------------------------------
# CONFIGURATION
# ---------------------------------------------------------------------
imageSourcePath="/home/fidel/Dropbox/Photos/WallpaperTest/"       # source image folder
baseFile="currentBaseWallpaper.png"                               # path for copy of selected file
generatedFile="currentGeneratedWallpaper.png"                    # filename for generated file



# ---------------------------------------------------------------------
# REQUIREMENTS
# ---------------------------------------------------------------------
# - Imagemagick:
command -v convert >/dev/null 2>&1 || { echo >&2 "Imagemagick is required but not installed.  Aborting."; exit 1; }


# ---------------------------------------------------------------------
# GENERATE CURRENT IMAGES IN WORKING DIR
# ---------------------------------------------------------------------
randomImage=$(find $imageSourcePath -type f | shuf -n 1)       # pick random image from source folder
convert "$randomImage"  $baseFile                              # copy random base image to project folder

# Create a dimmed & blur-verion of the image into the working dir
#
# dim - where -30 is to darken by 30 and +10 is to increase the contrast by 10.
convert "$randomImage" -channel RGBA  -blur 0x8 -brightness-contrast -30x10  $generatedFile



# ---------------------------------------------------------------------
# NOTIFICATION
# ---------------------------------------------------------------------
#notify-send "Generated new wallpaper" -i "~/Desktop/logo.png"
