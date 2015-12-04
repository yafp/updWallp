#!/bin/bash
#
#  Name:       errorStrings.sh
#  Function:   Defines all error codes and strings
#  Github:     https://github.com/yafp/updWallp
#

# ---------------------------------------------------------------------
# ERRORSTRINGS
# ---------------------------------------------------------------------

error01="${bold}${red}ERROR${normal} Unable to find 'config.sh'. Exiting (errorcode 1).\n"
error02="${bold}${red}ERROR${normal} Variable 'installationPath' is not configured (in config.sh) or not valid. Exiting (errorcode 2).\n"
error03="${bold}${red}ERROR${normal} No parameter. Try -h to get instructions. Exiting (errorcode 3).\n"
error04="${bold}${red}ERROR${normal} Invalid parameter '$primaryParameter'\n\nStart with: '-h' for some basic instructions. Exiting (errorcode 4)\n"
