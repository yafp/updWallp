#!/bin/bash
#
#  Name:       functions.sh
#  Function:   Contains the functions which all updWallp scripts might need
#  Github:     https://github.com/yafp/updWallp
#



# ---------------------------------------------------------------------
# CHECKUPDWALLPFOLDER
# ---------------------------------------------------------------------
function checkupdWallpFolder() {
   printf "...Checking updWallp working dir\n"
   if [ -d "$updWallpDir" ];                                                    # if script folder is defined
      then
      printf "...updWallp folder:\t\t$updWallpDir \t\t${bold}OK${normal}\n"      # can continue
   else
      displayNotification "updWallp" "updWallp folder not configured"
      printf "${bold}ERROR:${normal} updWallp folder not configured\n"
      printf "${bold}...aborting now${normal}"
      exit                                                              # otherwise die
   fi
}



# ---------------------------------------------------------------------
# NOTIFICATION
# ---------------------------------------------------------------------
function displayNotification() {
   if [ -f $notifyPath ];    # if notify-send exists
   then
      /usr/bin/notify-send "$1" "$2" -i "$updWallpDir/img/appIcon_128px.png"
   else
      printf "${bold}WARNING:${normal} notify-send not found\n"
   fi
}




# ---------------------------------------------------------------------
# SETLINUXWALLPAPER
# ---------------------------------------------------------------------
function setLinuxWallpaper() {
   printf "...Trying to activate the new wallpaper\n"

   if [ "$(pidof gnome-settings-daemon)" ]
     then
       printf "...Setting wallpaper using gsettings\t\t\t\t\t\t\t\t${bold}OK${normal}\n"
       gsettings set org.gnome.desktop.background picture-uri file://$updWallpDir/$1
       displayNotification "updWallp" "Wallpaper successfully set"
     else
       if [ -f ~/.xinitrc ]
       then
         if [ "$(which feh)" ]
         then
           printf "Gnome-settings-daemons not running, setting wallpaper with feh..."
           feh $outputFilename
           feh_xinitSet
         elif [ "$(which hsetroot)" ]
         then
           printf "Gnome-settings-daemons not running, setting wallpaper with hsetroot..."
           hsetroot -cover $outputFilename
           hsetroot_xinitSet
         elif [ "$(which nitrogen)" ]
         then
           printf "Gnome-settings-daemons not running, setting wallpaper with nitrogen..."
           nitrogen $outputFilename
           nitrogen_xinitSet
         else
           printf "You need to have either feh, hsetroot or nitrogen, bruhbruh."
           exit
         fi
       else
         printf "You should have a ~/.xinitrc file."
         exit
       fi
     fi
}
