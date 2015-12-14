# updWallp

![Logo](https://raw.githubusercontent.com/yafp/updWallp/master/img/appIcon_128px.png)


## About
**updWallp** is a small bash based project which creates nondistracting (blured/dimmed and some other stuff) wallpapers for your linux computer out of your images/photos.

The basic idea is inspired by [Muzei](https://github.com/romannurik/muzei/) and [LinMuzei](https://github.com/aepirli/linmuzei).



## How it works

**updWallp** offers 2 main operation modes.

In **local-mode** *updWallp.sh* is using a random image from a user-supplied local folder to generate a blured & dimmed copy of it and sets the new created image as wallpaper.

In **remote-mode** (aka *Muzei* mode) it picks the muzei-picture-of-the-day from the internet, generates a blured & dimmed version of it and sets the new created image as wallpaper.

The image-modification relies on ImageMagick and is user-adjustable.
Out of the box all output images of **updWallp** are blured and dimmed, in addition they might be grayscaled or sepia or colorized differently. They might be scaled to a user-defined width as well.

If you feel comfortable hacking the script you can go crazy and add tons of other parameters ImageMagick offers.

A second bash script (*updWallpShowOrg.sh*) offers the option to temporary toggle the wallpaper back to the original (non-blured & dimmed) version of the current wallpaper for x seconds.


## Example Outputs
The following source image

![updWallp_l](https://raw.githubusercontent.com/yafp/updWallp/master/doc/ss_exampleBase.png)

Using **local mode** (operationMode=1) and **normal** (imageModificationMode=0)

![updWallp_l](https://raw.githubusercontent.com/yafp/updWallp/master/doc/ss_exampleOutputMode0.png)

Using **local mode** (operationMode=1) and **grayscale** (imageModificationMode=1)

![updWallp_l](https://raw.githubusercontent.com/yafp/updWallp/master/doc/ss_exampleOutputMode1.png)

Using **local mode** (operationMode=1) and **sepia** (imageModificationMode=2)

![updWallp_l](https://raw.githubusercontent.com/yafp/updWallp/master/doc/ss_exampleOutputMode2.png)

Using in **local mode** (operationMode=1) and **colorize** (imageModificationMode=3)

![updWallp_l](https://raw.githubusercontent.com/yafp/updWallp/master/doc/ss_exampleOutputMode3.png)

Using **local mode** (operationMode=1) and **level-colors (here: black and lightgreen)** with (imageModificationMode=4)

![updWallp_l](https://raw.githubusercontent.com/yafp/updWallp/master/doc/ss_exampleOutputMode4.png)

Keep in mind that all parameters are changeable.


## Requirements
- ImageMagick (needed in general)

- cURL (needed in remote-mode to download images)

- jq (needed in remote-mode to parse the muzei.json)

- notify-send (optional for desktop notifications)


## How to get started in a few steps
### Get files
Downloads the latest build from [here](https://github.com/yafp/updWallp/archive/master.zip).

### Configuration (config.sh)
#### Define operationMode variable
You need to set the **operation mode** to either **local (1)** or **remote (2)**

Change
```bash
operationMode=""
```

to something like this (for local mode)
```bash
operationMode="1"
```

and in case of **local mode** you have to define the local image source folder as well

Change
```bash
localImageFolder=""
```

to something like this
```bash
localImageFolder="/full/path/to/your/local/image/folder"
```



### Usage
#### updWallp.sh (Mainscript)
Execute:

> ./updWallp.sh

Output (depends on the operation mode):

![updWallp_l](https://raw.githubusercontent.com/yafp/updWallp/master/doc/ss_updWallp_l.png)

or via cron
> */30 * * * * /path/to/updWallp/updWallp.sh >/dev/null 2>&1


#### updWallpShowOrg.sh (Togglescript)
Execute:

> ./updWallpShowOrg.sh

Output:

![updWallpShowOrg](https://raw.githubusercontent.com/yafp/updWallp/master/doc/ss_updWallpShowOrg.png)
