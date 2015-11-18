# updWallp

![Logo](https://raw.githubusercontent.com/yafp/updWallp/master/img/appIcon_128px.png)


## About updWallp
updWallp is a small bash based project which do handle dynamic blured & dimmed wallpapers for your Linux desktops.
It offers 2 operation modes - local and remote.

In local mode the main script (updWallp.sh) is using a radom image from a user-supplied local folder, generates a blured & dimmed version of this image and sets it as wallpaper.

In remote mode (aka Muzei mode) it picks the picture of the day Muzei offers from the internet, generates a blured & dimmed version of this image and sets it as wallpaper.

In addition a second scripts (updWallpShowOrg.sh) offers the option to temporary toggle back to the non-blured & dimmed version of the current wallpaper for x seconds.


The basic idea is inspired by Muzei and LinMuzei

- https://github.com/romannurik/muzei/

- https://github.com/aepirli/linmuzei



## Requirements
- ImageMagick (needed)

- cURL (needed in Remote mode: to download images)

- jq (needed in Remote mode: to parse the muzei.json)

- notify-send (optional: for desktop notifications)



## Usage
### updWallp.sh (Local mode)
Launch it manually

> ./updWallp.sh /path/to/yourLocalImageFolder

or via cron
> */30 * * * * /path/to/updWallp/updWallp.sh /path/to/yourLocalImageFolder >/dev/null 2>&1

### updWallp.sh (Remote mode)
Launch it manually

> ./updWallp.sh

or via cron
> */30 * * * * /path/to/updWallp/updWallp.sh >/dev/null 2>&1


### updWallpShowOrg.sh
Launch it manually

> ./updWallpShowOrg.sh
