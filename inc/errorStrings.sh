#!/bin/bash
#
#  Name:       errorStrings.sh
#  Function:   Defines all error codes and strings
#  Github:     https://github.com/yafp/updWallp
#

# ---------------------------------------------------------------------
# ERRORSTRINGS
# ---------------------------------------------------------------------
# error01 - happens early where the inc files arent loaded yet - therefore it doesnt make sense to define it inhere
error02="${bold}${red}ERROR${normal} Too many parameters\n\nStart with: '-h' for some basic instructions. Exiting (errno 2)\n"
error03="${bold}${red}ERROR${normal} Invalid parameter '$primaryParameter'\n\nStart with: '-h' for some basic instructions. Exiting (errno 3)\n"
error04="${bold}${red}ERROR${normal} Unexpected operating system: $OSTYPE. Exiting (errno 4).\n"
error05="${bold}${red}ERROR${normal} Undefined operation mode (operationMode) in config.sh. Exiting (errno 5).\n"
error06="${bold}${red}ERROR${normal} Unsupported operation mode (operationMode) in config.sh. Exiting (errno 6).\n"
