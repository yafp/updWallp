#!/bin/bash
#
#  Name:       appVersion.sh
#  Function:   Defines only the version of updWallp
#  Github:     https://github.com/yafp/updWallp
#

# ---------------------------------------------------------------------
# LOAD ALL FILES FROM INC FOLDER
# ---------------------------------------------------------------------


# source inc/constants.sh if possible
if [ -f inc/constants.sh ]; then
   source inc/constants.sh 				# load colorDefinitions.sh
else
   printf "updWallp - Can not source inc/constants.sh. Aborting\n"
   exit 99
fi




# source inc/colorDefinitions.sh if possible
if [ -f inc/colorDefinitions.sh ]; then
   source inc/colorDefinitions.sh 				# load colorDefinitions.sh
else
   printf "updWallp - Can not source inc/colorDefinitions.sh. Aborting\n"
   exit 99
fi


# source inc/errorStrings.sh if possible
if [ -f inc/errorStrings.sh ]; then
   source inc/errorStrings.sh 				# load errorStrings.sh
else
   printf "updWallp - Can not source inc/errorStrings.sh. Aborting\n"
   exit 99
fi


# source inc/appVersion.sh if possible
if [ -f inc/appVersion.sh ]; then
   source inc/appVersion.sh 				# load appVersion.sh
else
   printf "updWallp - Can not source inc/appVersion.sh. Aborting\n"
   exit 99
fi


# source inc/functions.sh if possible
if [ -f inc/functions.sh ]; then
   source inc/functions.sh 				# load  functions.sh
else
   printf "updWallp - Can not source inc/functions.sh. Aborting\n"
   exit 99
fi
