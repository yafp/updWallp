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
### In general
- ImageMagick (must have)

### For local mode
- nothing additional

### For remote mode (Muzei mode)
- cURL (to download images)

- jq (to parse the muzei.json)

### Nice to have
- notify-send (nice to have for notifications)



## Usage
### updWallp.sh (To set the blured & dimmed version as wallpaper)
#### Local mode
Launch it manually or via cron

> ./updWallp.sh /path/to/yourLocalImageFolder

#### Remote mode
Launch it manually or via cron

> ./updWallp.sh


### updWallpShowOrg.sh (To see the original version of the current wallpaper for x seconds)
Launch it manually

> ./updWallpShowOrg.sh


