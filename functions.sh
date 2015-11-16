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
   if [ -d "$updWallpDir" ];                                                    # if script folder is defined
      then
      printf "${bold}OK${normal} ... updWallp folder is set to: $updWallpDir\n"      # can continue
   else
      displayNotification "updWallp" "updWallp folder not configured"
      printf "${bold}ERROR:${normal} updWallp folder not configured. Aborting\n"
      exit                                                              # otherwise die
   fi
}





# ---------------------------------------------------------------------
# NOTIFICATION
# ---------------------------------------------------------------------
function displayNotification() {
   if [ -f $notifyPath ];    # if notify-send exists
   then
      $notifyPath "$1" "$2" -i "$updWallpDir/img/appIcon_128px.png"
   else
      printf "${bold}WARNING${normal} ... notify-send not found\n"
   fi
}




# ---------------------------------------------------------------------
# SETLINUXWALLPAPER
# ---------------------------------------------------------------------
function setLinuxWallpaper() {
   if [ "$(pidof gnome-settings-daemon)" ]
     then
       /usr/bin/gsettings set org.gnome.desktop.background picture-uri file://$updWallpDir/$1
       displayNotification "updWallp" "Wallpaper successfully set"
       printf "${bold}OK${normal} ... Wallpaper set via gsettings\n"
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
