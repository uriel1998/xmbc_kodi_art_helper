# xmbc_kodi_art_helper

Scripts to help with fanart and movie posters for Kodi/XMBC


# Copy All Fanart

**To get all the fanart from a video directory (e.g. Kodi, Plex) and copy it to 
a specified directory.**

This utility allows you to copy all the fanart from one set of directories to
another - without having (exact) duplicates by comparing sha1sums. You will 
end up with a directory full of `fanart_00000.jpg` files (unless you specify a 
different filename pattern, see below). 

The use case here is to have a directory of not (exactly) duplicated fan arts 
for use as backgrounds, screen wallpaper, a source for screensavers, and so on. 
For example, I synchronize the results with a cloud service so that a chromecast 
can use it for its screensaver.

The SHA sums are stored in a local file, so you can re-run the program and only 
catch new added files. By default, this is `$XDG_DATA_HOME/fanart_copier_shastore.txt`.

If you need to use this utility with multiple output directories, you can 
specify a *different* SHA sum store with a commandline switch. (For example, 
if you wanted to have one output directory that was *just* TV show fanart and 
another that was TV show fanart *and* movie fanart.

`copy_all_fanart [--shastore /path/to/file] [--clear] /sourcedir /outdir [pattern]` 

For example:

`copy_all_fanart /media/TV /home/steven/wallpapers TV_wallpaper`

would result in the fanart from my TV show store to the directory 
`/home/steven/wallpapers` with filenames like `TV_wallpaper_000000.jpg` and 
`TV_wallpaper_000001.jpg`, and so on.

Notes: 

* No trailing slash on paths. 

* To specify the SHASTORE (so you can use this with multiple OUT directories) 
have your **FIRST** commandline switch be `--shastore /full/file/path/to/sha_store` 

* To clear the SHASTORE in use, use the `--clear` as the first switch (if you 
are using the default SHASTORE, if you are using a specific one, you must specify 
the SHASTORE first.

* [pattern] is optional, and your files have that at the beginning of the filename. 
Do not have whitespace in this pattern.


# Make Video Fanart

**To create posters, fanart, or thumbnails for those videos which do not have them.**

Note: This *creates* fanart, it does NOT *retrieve* it. The primary use case that 
I wrote it for is when I have a personal video in my library that is not any 
kind of "official" release that has fan art and I just want *something* in there.

For the purposes of retrieving and organizing fanart, I highly recommend (and use)  [TinyMediaManager](https://www.tinymediamanager.org/).

This script will create:

fanart.jpg
poster.jpg
filename-fanart.jpg
filename-poster.jpg 
season##-poster.jpg
filename-thumbnail.jpg

It will use existing fanart, if found, to create the posters, otherwise it will 
use `ffmpeg` to get a clip from the video file and format it. 

Usage is pretty straightforward.

`make_video_fanart.sh /base/directory/of/videos [ --fanart | --thumbnail | --poster | -all ]`


