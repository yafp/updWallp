#!/bin/bash
#
#  Name:       constants.sh
#  Function:   Defines some string constants we are using on several places
#  Github:     https://github.com/yafp/updWallp
#

# ---------------------------------------------------------------------
# CONSTANT STRINGS
# ---------------------------------------------------------------------
readonly appName="updWallp"                                       # AppName
readonly appSubTitle="the wallpaper refresher"
readonly appDocURL="https://github.com/yafp/updWallp/wiki"        # URL of project wiki
readonly appIssueURL="https://github.com/yafp/updWallp/issues"    # issue tracker


# FILENAMES for ImageCreation
#
# local
backupFilename="tmp/currentBaseWallpaper.png"             # filename for backup copy of selected file
workInProgess="tmp/currentWorkInProgress.png"             # filename while processing
outputFilename="tmp/currentGeneratedWallpaper.png"        # generated Wallpaper which is set as wallpaper
# remote
muzeiFilename="tmp/muzeiImage.png"


primaryParameter=$1
