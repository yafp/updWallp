#!/bin/bash
#
#  Name:       colorDefinitions.sh
#  Function:   Defines the color-codes for terminal output of updWallp
#  Github:     https://github.com/yafp/updWallp
#

# ---------------------------------------------------------------------
# COLOR DEFINITIONS - DONT TOUCH
# ---------------------------------------------------------------------

# format
bold=$(tput bold)
normal=$(tput sgr0)
blink=$(tput blink)
reverse=$(tput smso)
underline=$(tput smul)

# colors
black=$(tput setaf 0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
lime_yellow=$(tput setaf 190)
powder_blue=$(tput setaf 153)
blue=$(tput setaf 4)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)
