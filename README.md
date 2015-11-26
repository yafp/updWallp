# updWallp

![Logo](https://raw.githubusercontent.com/yafp/updWallp/master/img/appIcon_128px.png)


## About updWallp
**updWallp** is a small bash based project which creates blured & dimmed wallpapers for your Linux desktops.
It offers 2 operation modes - local and remote.

In **local-mode** *updWallp.sh* is using a random image from a user-supplied local folder to generate a blured & dimmed copy of it  and sets the new created image as wallpaper.

In **remote-mode** (aka *Muzei* mode) it picks the muzei-picture-of-the-day from the internet, generates a blured & dimmed version of it and sets the new created image as wallpaper.


A second bash script (*updWallpShowOrg.sh*) offers the option to temporary toggle back to the original (non-blured & dimmed) version of the current wallpaper for x seconds.


The basic idea is inspired by Muzei and LinMuzei

- https://github.com/romannurik/muzei/

- https://github.com/aepirli/linmuzei



## Requirements
- ImageMagick (needed)

- cURL (needed in Remote mode to download images)

- jq (needed in Remote mode to parse the muzei.json)

- notify-send (optional for desktop notifications)


## How to get started in a few steps
### Get files
Downloads the latest build from https://github.com/yafp/updWallp/archive/master.zip

### Configuration
As initial step you have to define the installation directory in the two major script **updWallp.sh** and **updWallpShowOrg.sh**. 

Please see the following example:

Change
```bash
updWallpDir=""
```

to something similar to this
```bash
updWallpDir="/home/username/path/to/updWallpFolder"
```

After that you can do the finetuning in **config.sh**.


### Usage
#### updWallp.sh 
##### General
![updWallp_h](https://raw.githubusercontent.com/yafp/updWallp/master/doc/ss_updWallp_h.png)

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


#### updWallpShowOrg.sh
![updWallpShowOrg_h](https://raw.githubusercontent.com/yafp/updWallp/master/doc/ss_updWallpShowOrg_h.png)

Launch it manually

> ./updWallpShowOrg.sh

Output:

![updWallpShowOrg](https://raw.githubusercontent.com/yafp/updWallp/master/doc/ss_updWallpShowOrg.png)
