# updWallp

![Logo](https://raw.githubusercontent.com/yafp/updWallp/master/img/appIcon_128px.png)


## About
**updWallp** is a small bash based project which creates non-distracting (blured/dimmed and some other stuff) wallpapers for your linux computer out of your images/photos.

The basic idea is inspired by [Muzei](https://github.com/romannurik/muzei/) and [LinMuzei](https://github.com/aepirli/linmuzei).



## How it works

**updWallp** offers 2 main operation modes.

In **local-mode** *updWallp.sh* is using a random image from a user-supplied local folder to generate a blured & dimmed copy of it and sets the new created image as wallpaper.

In **remote-mode** (aka *Muzei* mode) it picks the muzei-picture-of-the-day from the internet, generates a blured & dimmed version of it and sets the new created image as wallpaper.

The image-modification relies on ImageMagick and is user-adjustable.
Out of the box all output images of **updWallp** are blured and dimmed, in addition they might be grayscaled or sepia. They might be scaled to a user-defined width as well.

If you feel comfortable hacking the script you can go crazy and add tons of other parameters ImageMagick offers.

A second bash script (*updWallpShowOrg.sh*) offers the option to temporary toggle back to the original (non-blured & dimmed) version of the current wallpaper for x seconds.



## Requirements
- ImageMagick (needed)

- cURL (needed in Remote mode to download images)

- jq (needed in Remote mode to parse the muzei.json)

- notify-send (optional for desktop notifications)


## How to get started in a few steps
### Get files
Downloads the latest build from [here](https://github.com/yafp/updWallp/archive/master.zip).

### Configuration
As initial step you have to define the installation directory in the main configuration script **config.sh**.

Change
```bash
installationPath=""
```

to something like this
```bash
installationPath="/home/username/path/to/updWallpFolder"
```



### Usage
#### updWallp.sh (Mainscript)
##### Local-mode
Launch it manually

> ./updWallp.sh -l /path/to/yourLocalImageFolder

Output:

![updWallp_l](https://raw.githubusercontent.com/yafp/updWallp/master/doc/ss_updWallp_l.png)

or via cron
> */30 * * * * /path/to/updWallp/updWallp.sh -l /path/to/yourLocalImageFolder >/dev/null 2>&1

##### Remote-mode
Launch it manually

> ./updWallp.sh -r

Output:

![updWallp_r](https://raw.githubusercontent.com/yafp/updWallp/master/doc/ss_updWallp_r.png)

or via cron
> */30 * * * * /path/to/updWallp/updWallp.sh -r >/dev/null 2>&1


#### updWallpShowOrg.sh (Togglescript)
Launch it manually

> ./updWallpShowOrg.sh

Output:

![updWallpShowOrg](https://raw.githubusercontent.com/yafp/updWallp/master/doc/ss_updWallpShowOrg.png)
