# updWallp

![Logo](https://raw.githubusercontent.com/yafp/updWallp/master/img/appIcon_128px.png)


## About updWallp
updWallp is a small bash script which picks a random image from a user-defined local folder,
generates a dimmed & blured version of it and set that as new wallpaper on your linux desktop

The basic idea is inspired by Muzei

- https://github.com/romannurik/muzei/

and

- https://github.com/aepirli/linmuzei



## Requirements
- ImageMagick (must have)

- notify-send (nice to have for notifications)



## Usage
Launch it manually or via cron

> ./updWallp.sh /path/to/yourImageSourceFolder


## What it does
- scripts chooses a random image from the source folder

- creates a fallback copy of that image

- creates a dimmed and blured copy of that image

- sets the dimmed and blured copy of that image as new wallpaper
