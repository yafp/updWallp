#!/bin/bash
#
#  Name:       appVersion.sh
#  Function:   Defines only the version of updWallp
#  Github:     https://github.com/yafp/updWallp
#

# ---------------------------------------------------------------------
# LOAD ALL FILES FROM INC FOLDER
# ---------------------------------------------------------------------

# source config.sh if possible
if [ -f config.sh ]
then
   source config.sh 				# load the config file
else
   printf "updWallp - Can not source config.sh. Aborting"
   exit
fi



# source inc/functions.sh if possible
if [ -f inc/functions.sh ]
then
   source inc/functions.sh 				# load  functions.sh
else
   printf "updWallp - Can not source inc/functions.sh. Aborting"
   exit
fi



# source inc/appVersion.sh if possible
if [ -f inc/appVersion.sh ]
then
   source inc/appVersion.sh 				# load appVersion.sh
else
   printf "updWallp - Can not source inc/appVersion.sh. Aborting"
   exit
fi



# source inc/colorDefinitions.sh if possible
if [ -f inc/colorDefinitions.sh ]
then
   source inc/colorDefinitions.sh 				# load colorDefinitions.sh
else
   printf "updWallp - Can not source inc/colorDefinitions.sh. Aborting"
   exit
fi
